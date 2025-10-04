# Spear - Plataforma Freelance Web3

Una plataforma descentralizada para freelancers con escrow inteligente, pagos por milestones y 0% de comisiones.

## 🚀 Características

- **0% Comisiones** (1-3% con protección premium)
- **Pagos por Milestones** - Los fondos se liberan por fases completadas
- **Escrow Seguro** - Smart contracts protegen a ambas partes
- **Fondos de Riesgo** - Protección opcional contra cancelaciones
- **Límites Inteligentes** - Máximo 5 proyectos activos por desarrollador
- **Expiración Automática** - Proyectos expiran en 7 días si no se asignan

## 📋 Información del Contrato

- **Red:** Sepolia Testnet
- **Dirección:** `0x9979F6a5cE685Fca312f933Cf942C19faBF7e96d`
- **Explorador:** [Ver en Etherscan](https://sepolia.etherscan.io/address/0x9979F6a5cE685Fca312f933Cf942C19faBF7e96d)

## 🛠️ Instalación y Desarrollo

### Prerrequisitos
- Node.js 16+
- MetaMask
- ETH de testnet en Sepolia

### Configuración
```bash
# Clonar repositorio
git clone <repo-url>
cd Spear

# Instalar dependencias
npm install

# Compilar contratos
npm run compile

# Ejecutar tests
npm run test

# Iniciar servidor de desarrollo
npm run dev
```

### Deployment
```bash
# Configurar clave privada en hardhat.config.js
# Obtener ETH de testnet: https://sepoliafaucet.com/

# Deploy a Sepolia
npm run deploy

# Verificar contrato
npx hardhat verify --network sepolia 0x9979F6a5cE685Fca312f933Cf942C19faBF7e96d
```

## 📖 Cómo Usar

### Para Clientes
1. Conecta tu wallet MetaMask
2. Cambia a Sepolia Testnet
3. Crea un proyecto definiendo:
   - Descripción del trabajo
   - Milestones en ETH (ej: 0.1,0.2,0.3)
   - Fondo de riesgo opcional
   - Nivel de protección
4. Los desarrolladores pueden aplicar
5. Aprueba al desarrollador elegido
6. Libera pagos por milestone completado

### Para Desarrolladores
1. Conecta tu wallet
2. Aplica a proyectos abiertos
3. Espera aprobación del cliente
4. Completa milestones para recibir pagos
5. Máximo 5 proyectos activos simultáneos

## 🏗️ Arquitectura

```
Spear/
├── contracts/
│   └── SpearEscrow.sol      # Contrato principal
├── src/
│   └── mitsu_lancer.html    # Frontend Web3
├── test/
│   └── SpearEscrow.js       # Tests del contrato
├── scripts/
│   └── deploy.js            # Script de deployment
└── ignition/modules/
    └── SpearModule.js       # Módulo de deployment
```

## 🔧 Funciones del Contrato

### Principales
- `createProject()` - Crear nuevo proyecto con milestones
- `applyToProject()` - Aplicar como desarrollador
- `approveDeveloper()` - Aprobar desarrollador (solo cliente)
- `completeMilestone()` - Marcar milestone como completado
- `cancelProject()` - Cancelar proyecto (reembolso parcial)

### Límites y Reglas
- Monto mínimo: 10 USDT
- Tiempo de vida: 7 días para proyectos abiertos
- Máximo 25 solicitudes activas por desarrollador
- Máximo 5 proyectos en progreso por desarrollador

## 🛡️ Seguridad

- ✅ Contratos auditados y testeados
- ✅ Validación de inputs sanitizada
- ✅ Protección contra reentrancy
- ✅ Manejo seguro de fondos
- ✅ Scripts CDN con verificación de integridad

## 🌐 Redes Soportadas

- **Sepolia Testnet** (Actual)
- **Moonbeam** (Polkadot - Futuro)
- **Moonriver** (Kusama - Futuro)

## 📄 Licencia

MIT License - Ver archivo LICENSE para detalles.

## 🤝 Contribuir

1. Fork del repositorio
2. Crear rama feature (`git checkout -b feature/nueva-funcionalidad`)
3. Commit cambios (`git commit -am 'Agregar nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Crear Pull Request

## 📞 Soporte

- **Issues:** [GitHub Issues](https://github.com/tu-usuario/spear/issues)
- **Documentación:** [Wiki del proyecto](https://github.com/tu-usuario/spear/wiki)

---

**Spear** - Revolucionando el freelance con Web3 🚀