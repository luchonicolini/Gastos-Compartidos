# Gastos Compartidos · iOS

> **English:** A native iOS app for tracking shared expenses, calculating individual balances and suggesting settlement payments. Built with SwiftUI, SwiftData and an MVVM structure.

[![iOS build and tests](https://github.com/luchonicolini/Gastos-Compartidos/actions/workflows/ios.yml/badge.svg?branch=main)](https://github.com/luchonicolini/Gastos-Compartidos/actions/workflows/ios.yml)

Compartir gastos de un viaje o una convivencia exige registrar quién pagó y cuánto le corresponde a cada integrante.
Esta aplicación reúne esos movimientos por grupo, calcula los balances y propone pagos para saldar las cuentas.

**Estado:** proyecto en desarrollo. Persistencia local; no se incluye un enlace de publicación verificado.

## Vista previa

[COMPLETAR: captura de la lista de grupos, carga de gasto y balances en un simulador iOS]

## Funcionalidades

- Crear, editar y eliminar grupos; administrar sus integrantes.
- Registrar y editar gastos con un pagador y varios participantes.
- Dividir en partes iguales, por monto fijo, porcentaje o partes.
- Consultar balances individuales y sugerencias de liquidación.
- Registrar y eliminar pagos de liquidación y recalcular los saldos.
- Guardar datos localmente con SwiftData.

## Stack y arquitectura

| Área | Implementación |
| --- | --- |
| Interfaz | SwiftUI |
| Lenguaje y destino | Swift 5; iOS 17.5 o posterior, según el proyecto Xcode |
| Estado de presentación | ViewModels con Observation; organización MVVM |
| Persistencia | Modelos SwiftData: Group, Person, Expense y SettlementPayment |
| Pruebas | XCTest sobre el ViewModel y modelos en un contenedor SwiftData en memoria |
| Integración continua | GitHub Actions, macOS y simulador iOS |

Las vistas presentan el estado; los ViewModels coordinan acciones y cálculos; los modelos representan las relaciones persistentes.
La lógica de balances todavía vive en `GroupDetailViewModel`: no se presenta como una capa de dominio independiente.
Los importes de esta versión usan `Double` y redondeo a dos decimales; migrar a una representación exacta es una mejora futura.

| Directorio | Responsabilidad |
| --- | --- |
| `ContextoGestion/Models/` | Entidades y errores del dominio |
| `ContextoGestion/ViewModel/` | Estado, balances y liquidaciones |
| `ContextoGestion/Views/` | Grupos, integrantes y gastos |
| `ContextoGestion/ContextoGestion/` | Entrada de la app, recursos y configuración |
| `ContextoGestion/ContextoGestionTests/` | Pruebas unitarias |
| `ContextoGestion/ContextoGestionUITests/` | Pruebas de arranque existentes; no equivalen a cobertura E2E del producto |

## Cómo ejecutarlo

1. Instalá Xcode en macOS con un runtime de simulador iOS compatible.
2. Cloná y abrí el proyecto:

   ```bash
   git clone https://github.com/luchonicolini/Gastos-Compartidos.git
   cd Gastos-Compartidos
   open ContextoGestion/ContextoGestion.xcodeproj
   ```

3. Seleccioná el esquema compartido **ContextoGestion**.
4. Elegí un simulador con iOS 17.5 o posterior y ejecutá con **⌘R**.
5. Para un dispositivo físico, configurá tu propio equipo y firma en **Signing & Capabilities**.

## Tests y CI

En Xcode, **⌘U** ejecuta los tests del esquema compartido. Por terminal:

```bash
xcrun simctl list devices available
# Reemplazá <UDID> por el identificador de un simulador iPhone compatible.
xcodebuild test \
  -project ContextoGestion/ContextoGestion.xcodeproj \
  -scheme ContextoGestion \
  -destination 'platform=iOS Simulator,id=<UDID>' \
  -only-testing:ContextoGestionTests \
  CODE_SIGNING_ALLOWED=NO
```

Las pruebas cubren grupos vacíos, balances iniciales, las cuatro divisiones, redondeo,
identidad de integrantes con nombres iguales y el efecto de pagos parciales y totales.
Usan datos en memoria; no modifican la base local de una instalación existente.

El [workflow](.github/workflows/ios.yml) compila la app y ejecuta los tests unitarios en cada PR y push a `main`.
Selecciona un simulador disponible en `macos-15` y conserva el resultado `.xcresult` durante siete días.
Necesita macOS porque SwiftUI, SwiftData y el simulador dependen del SDK de Apple.
No distribuye la app ni requiere certificados de App Store.
El badge muestra el estado de `main`; antes de integrar el PR, consultá sus checks.

## Próximos pasos

- Migrar los importes a centavos o un tipo de dinero exacto, con pruebas de compatibilidad.
- Ampliar casos límite y pruebas del flujo completo de persistencia e interfaz.
- Revisar accesibilidad y comportamiento en dispositivos físicos.
- Preparar capturas y documentación de distribución.

## Pendientes de presentación

- [COMPLETAR: captura de la lista de grupos, carga de gasto y balances en un simulador iOS]
- [COMPLETAR: enlace a App Store o TestFlight si existe una publicación]

## Autor

[Luciano Nicolini](https://github.com/luchonicolini) · iOS Developer (Swift, SwiftUI).
