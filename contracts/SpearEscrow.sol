// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract SpearEscrow {
    enum ProjectStatus { Open, InProgress, Completed, Cancelled, Expired }
    enum ProtectionLevel { Basic, Premium }
    
    struct Project {
        address client;
        address developer;
        uint256 totalAmount;
        uint256 riskFund;
        uint256[] milestoneAmounts;
        bool[] milestonesCompleted;
        ProtectionLevel protection;
        ProjectStatus status;
        uint256 createdAt;
        uint256 expiresAt;
        string description;
        bool riskFundApproved;
    }
    
    struct Request {
        address developer;
        uint256 createdAt;
        bool active;
    }
    
    mapping(uint256 => Project) public projects;
    mapping(address => uint256) public activeProjects;
    mapping(address => uint256) public activeRequests;
    mapping(uint256 => Request[]) public projectRequests;
    
    uint256 public projectCounter;
    uint256 public constant MIN_AMOUNT = 10e6; // 10 USDT
    uint256 public constant REQUEST_LIFETIME = 48 hours;
    uint256 public constant PROJECT_LIFETIME = 7 days;
    uint256 public constant MAX_ACTIVE_PROJECTS = 5;
    uint256 public constant MAX_ACTIVE_REQUESTS = 25;
    
    address public admin;
    
    event ProjectCreated(uint256 indexed projectId, address indexed client, uint256 amount);
    event DeveloperApplied(uint256 indexed projectId, address indexed developer);
    event DeveloperApproved(uint256 indexed projectId, address indexed developer);
    event MilestoneCompleted(uint256 indexed projectId, uint256 milestone);
    event ProjectCompleted(uint256 indexed projectId);
    event ProjectCancelled(uint256 indexed projectId, uint256 refundAmount);
    
    modifier onlyClient(uint256 _projectId) {
        require(msg.sender == projects[_projectId].client, "Only client");
        _;
    }
    
    modifier onlyDeveloper(uint256 _projectId) {
        require(msg.sender == projects[_projectId].developer, "Only developer");
        _;
    }
    
    constructor() {
        admin = msg.sender;
    }
    
    function createProject(
        string memory _description,
        uint256[] memory _milestoneAmounts,
        uint256 _riskFund,
        ProtectionLevel _protection
    ) external payable {
        require(msg.value >= MIN_AMOUNT, "Minimum 10 USDT");
        require(_milestoneAmounts.length > 0, "Need milestones");
        
        uint256 totalMilestones = 0;
        for(uint i = 0; i < _milestoneAmounts.length; i++) {
            totalMilestones += _milestoneAmounts[i];
        }
        require(msg.value >= totalMilestones + _riskFund, "Insufficient funds");
        
        projectCounter++;
        
        projects[projectCounter] = Project({
            client: msg.sender,
            developer: address(0),
            totalAmount: totalMilestones,
            riskFund: _riskFund,
            milestoneAmounts: _milestoneAmounts,
            milestonesCompleted: new bool[](_milestoneAmounts.length),
            protection: _protection,
            status: ProjectStatus.Open,
            createdAt: block.timestamp,
            expiresAt: block.timestamp + PROJECT_LIFETIME,
            description: _description,
            riskFundApproved: false
        });
        
        emit ProjectCreated(projectCounter, msg.sender, totalMilestones);
    }
    
    function applyToProject(uint256 _projectId) external {
        require(projects[_projectId].status == ProjectStatus.Open, "Project not open");
        require(block.timestamp < projects[_projectId].expiresAt, "Project expired");
        require(activeProjects[msg.sender] < MAX_ACTIVE_PROJECTS, "Too many active projects");
        require(activeRequests[msg.sender] < MAX_ACTIVE_REQUESTS, "Too many requests");
        
        projectRequests[_projectId].push(Request({
            developer: msg.sender,
            createdAt: block.timestamp,
            active: true
        }));
        
        activeRequests[msg.sender]++;
        emit DeveloperApplied(_projectId, msg.sender);
    }
    
    function approveDeveloper(uint256 _projectId, address _developer) external onlyClient(_projectId) {
        require(projects[_projectId].status == ProjectStatus.Open, "Project not open");
        
        projects[_projectId].developer = _developer;
        projects[_projectId].status = ProjectStatus.InProgress;
        activeProjects[_developer]++;
        
        Request[] storage requests = projectRequests[_projectId];
        for(uint i = 0; i < requests.length; i++) {
            if(requests[i].active) {
                activeRequests[requests[i].developer]--;
                requests[i].active = false;
            }
        }
        
        emit DeveloperApproved(_projectId, _developer);
    }
    
    function completeMilestone(uint256 _projectId, uint256 _milestone) external onlyClient(_projectId) {
        Project storage project = projects[_projectId];
        require(project.status == ProjectStatus.InProgress, "Project not in progress");
        require(_milestone < project.milestoneAmounts.length, "Invalid milestone");
        require(!project.milestonesCompleted[_milestone], "Already completed");
        
        project.milestonesCompleted[_milestone] = true;
        payable(project.developer).transfer(project.milestoneAmounts[_milestone]);
        
        emit MilestoneCompleted(_projectId, _milestone);
        
        bool allCompleted = true;
        for(uint i = 0; i < project.milestonesCompleted.length; i++) {
            if(!project.milestonesCompleted[i]) {
                allCompleted = false;
                break;
            }
        }
        
        if(allCompleted) {
            project.status = ProjectStatus.Completed;
            activeProjects[project.developer]--;
            
            if(project.riskFund > 0 && project.riskFundApproved) {
                payable(project.client).transfer(project.riskFund);
            }
            
            emit ProjectCompleted(_projectId);
        }
    }
    
    function cancelProject(uint256 _projectId) external onlyClient(_projectId) {
        Project storage project = projects[_projectId];
        require(project.status == ProjectStatus.InProgress, "Cannot cancel");
        
        project.status = ProjectStatus.Cancelled;
        activeProjects[project.developer]--;
        
        uint256 refundAmount = 0;
        for(uint i = 0; i < project.milestonesCompleted.length; i++) {
            if(!project.milestonesCompleted[i]) {
                refundAmount += project.milestoneAmounts[i];
            }
        }
        
        if(project.riskFund > 0 && project.riskFundApproved) {
            payable(project.developer).transfer(project.riskFund);
        } else {
            refundAmount += project.riskFund;
        }
        
        if(refundAmount > 0) {
            payable(project.client).transfer(refundAmount);
        }
        
        emit ProjectCancelled(_projectId, refundAmount);
    }
    
    function renewProject(uint256 _projectId) external onlyClient(_projectId) {
        require(projects[_projectId].status == ProjectStatus.Open, "Project not renewable");
        projects[_projectId].expiresAt = block.timestamp + PROJECT_LIFETIME;
    }
    
    function approveRiskFund(uint256 _projectId) external onlyDeveloper(_projectId) {
        projects[_projectId].riskFundApproved = true;
    }
}