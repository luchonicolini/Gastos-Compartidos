<div align="center">
  <img src="ContextoGestion/ContextoGestion/Assets.xcassets/AppIcon.appiconset/AppIcon~ios-marketing.png" width="120" alt="Ícono de Gastos Compartidos">

  # Gastos Compartidos

  **Una aplicación iOS para organizar gastos en grupo y saber quién debe pagarle a quién.**

  ![Swift](https://img.shields.io/badge/Swift-5.0-F05138?logo=swift&logoColor=white)
  ![SwiftUI](https://img.shields.io/badge/SwiftUI-iOS-0D96F6?logo=swift&logoColor=white)
  ![iOS](https://img.shields.io/badge/iOS-17.5%2B-000000?logo=apple&logoColor=white)
  ![Estado](https://img.shields.io/badge/estado-en%20desarrollo-F59E0B)
</div>

## Descripción

Gastos Compartidos simplifica la administración de gastos entre amigos, parejas o grupos de viaje. Permite registrar participantes y consumos, dividir cada importe de distintas maneras y calcular automáticamente los pagos necesarios para saldar las cuentas.

El proyecto fue desarrollado de forma nativa para iOS con **SwiftUI** y utiliza **SwiftData** para guardar la información localmente.

## Funcionalidades

- Creación, edición y eliminación de grupos.
- Administración de integrantes.
- Registro y edición de gastos.
- Selección de la persona que realizó el pago.
- División equitativa, por monto fijo, porcentaje o partes.
- Cálculo de balances individuales.
- Sugerencias de pagos para saldar las deudas del grupo.
- Persistencia local de datos con SwiftData.
- Interfaz adaptable al modo claro y oscuro.
- Consideraciones de accesibilidad y reducción de movimiento.

## Tecnologías

- **Swift 5**
- **SwiftUI**
- **SwiftData**
- **MVVM**
- **XCTest y XCUITest**
- **Google Mobile Ads SDK**
- **Xcode**

## Arquitectura

El código está organizado siguiendo una separación basada en MVVM:

```text
ContextoGestion/
├── ContextoGestion/        # Punto de entrada, recursos y configuración
├── Models/                 # Modelos de dominio y persistencia
├── ViewModel/              # Estado y lógica de presentación
├── Views/
│   ├── Main/               # Pantallas de grupos
│   └── Details/            # Gastos, miembros y liquidaciones
├── Introducion/            # Componentes y utilidades compartidas
├── GoogleAds/              # Integración de anuncios
├── ContextoGestionTests/   # Pruebas unitarias
└── ContextoGestionUITests/ # Pruebas de interfaz
```

## Requisitos

- macOS con Xcode
- iOS 17.5 o posterior
- Swift 5.0 o posterior

## Instalación

1. Cloná este repositorio:

   ```bash
   git clone https://github.com/luchonicolini/Gastos-Compartidos.git
   ```

2. Abrí el proyecto en Xcode:

   ```bash
   open ContextoGestion/ContextoGestion.xcodeproj
   ```

3. Seleccioná un simulador o dispositivo compatible.
4. Verificá las dependencias del proyecto y ejecutalo con `⌘R`.

## Estado del proyecto

El proyecto se encuentra en desarrollo. La estructura y las funcionalidades principales están implementadas, pero pueden producirse cambios antes de una versión estable.

## Autor

Desarrollado por [Luciano Nicolini](https://github.com/luchonicolini).

Si el proyecto te resulta útil o interesante, podés dejar una ⭐ en el repositorio.
