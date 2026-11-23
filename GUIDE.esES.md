# Guía de Panorama

Cómo usar Panorama en WoW Forever y cómo configurar HDR en Windows.

**Primero, haz una copia de tus ajustes.** Panorama cambia ajustes del juego, y quitar el addon no los devuelve a su estado anterior. Antes de cambiar nada, cierra el juego y copia la carpeta `WTF` de tu instalación del juego en un lugar seguro. Para volver atrás, cierra el juego y vuelve a poner esa copia en su sitio.

## 1. Abrir la ventana

- Escribe `/pano` o haz clic izquierdo en el botón de Panorama del minimapa.
- En Opciones > AddOns > Panorama también hay un botón que la abre.
- Arrastra la barra de título para mover la ventana. Escape o el botón de cierre la cierra.

El botón del minimapa:

- El clic izquierdo abre o cierra la ventana.
- El clic derecho muestra los preajustes, deshacer, rehacer y el reinicio de los gráficos.
- Arrástralo para moverlo alrededor del minimapa. `/pano minimap` lo muestra u oculta.

## 2. La ventana

| Parte | Qué hace |
|---|---|
| Cuadro de búsqueda (arriba a la derecha) | Escribe una palabra para listar los ajustes que coinciden de todas las pestañas. Bórrala para volver. |
| Pestañas | Calidad, Interfaz, Avanzado (ajustes del juego), luego Filtros, Mis filtros, Ambiente (efectos de Panorama). Se recuerda la pestaña abierta. |
| Ajustes avanzados (bajo el título) | Sin marcar: sin pestañas, una sola página con los preajustes, los ajustes principales de calidad (distancia de visión, niebla volumétrica, sombras, oclusión ambiental, detalle del agua, suavizado de bordes, atenuación de la nitidez), la salida HDR y el brillo máximo, el contraste, el brillo, la distancia de la cámara, el filtro, la intensidad del filtro y el modo de ambiente. Marcado: todas las pestañas y todos los ajustes. En la primera instalación está sin marcar; si ya usabas Panorama, está marcado. La búsqueda siempre encuentra todos los ajustes. |
| Deshacer, Rehacer (bajo las pestañas, a la derecha) | Deshacer anula tu último cambio: control deslizante, casilla, preajuste, filtro, ambiente o Restablecer todo. Rehacer lo recupera. Los últimos 20 cambios se conservan hasta `/reload`. |
| Selector de idioma (a la derecha de las pestañas) | Idioma del juego o uno de diez idiomas. Al cambiarlo se recarga la interfaz. |
| Guía (a la izquierda del cuadro de búsqueda) | Abre esta guía en el juego. |
| Preajustes (pestaña Calidad) | Bajo, Medio, Alto, Extra. Se resalta el preajuste que coincide con tus ajustes. |
| Pie | Aplicar en cada conexión, botón del minimapa, Restablecer todo, reinicio del motor gráfico. |

Haz clic en el título de una sección para plegarla o desplegarla.

### Una línea de ajuste

- **Control deslizante**: el valor se escribe al soltar el botón del ratón, no mientras arrastras.
- **Cuadro de valor** junto al control deslizante: escribe un valor y pulsa Intro o haz clic en otro sitio.
  Escape cancela, Tab pasa al cuadro siguiente. La coma sirve como separador decimal. El valor se mantiene
  dentro del rango del control deslizante.
- **Botón Predeterminado**: devuelve ese ajuste a su valor predeterminado. Pasa el ratón por encima para
  ver el valor.
- **Marca dorada** a la izquierda: has cambiado este ajuste.
- **Estrella amarilla**: un menú del juego también establece este valor. Pasa el ratón por encima para
  ver cuál. Ese menú no vuelve a leer el valor, así que puede mostrar otro nivel.
- **Línea en gris**: depende de otro ajuste que está desactivado (por ejemplo, la densidad de la niebla
  sin niebla volumétrica, la intensidad del tono sin un tono). La línea indica qué ajuste cambiar.
- Pasa el ratón por una etiqueta para leer su ayuda completa.

## 3. Preajustes

| Preajuste | Resultado |
|---|---|
| Bajo | Máximo rendimiento. Poca distancia de visión, sin sombras. |
| Medio | Equilibrado. Buen rendimiento y sombras correctas. |
| Alto | Nivel Alto del juego. Sombras completas, todos los efectos. |
| Extra | Alto, con la mayor distancia de visión. |

Los preajustes solo cambian los ajustes de calidad gráfica de la pestaña Calidad. No tocan la cámara,
el ratón, la interfaz, el enfoque, la baja latencia, HDR ni los filtros.

¿Has cambiado de opinión? **Deshacer** (bajo las pestañas, o `/pano undo`)
restaura los ajustes de antes del preajuste.

## 4. Filtros

La pestaña Filtros añade efectos sobre la imagen. No cambian ningún ajuste del juego.

- **Tono**: haz clic en una miniatura para aplicarlo al instante (Sepia, Cálido, Frío, Noche, Esmeralda,
  Crepúsculo). **Intensidad del tono** define su fuerza.
- **Mi filtro**: usa uno de tus filtros de la pestaña Mis filtros. Sustituye el tono, la viñeta y el grano.
- **Cielo**: los mismos colores en degradado, completos arriba de la pantalla y más claros abajo.
  **Intensidad del cielo** define su fuerza.
- **Viñeta**: oscurece los bordes de la pantalla.
- **Grano**: grano animado.
- **Barras negras**: barras superior e inferior, de 0 a 20 % de la pantalla cada una. El juego sigue
  renderizando lo que ocultan, así que no aumentan la tasa de fotogramas.

### Ambiente

La pestaña Ambiente cambia sola el tinte, el cielo, la viñeta y el grano según dónde estés.

- **Modo** (parte superior de la pestaña): **Desactivado** (la pestaña Filtros se aplica en todas partes), **Día y noche automáticos** (ver Día y noche más abajo) o **Ambiente automático**. Desactivado por defecto.
- **Ambiente automático**: estos filtros siguen el lugar y la hora del día. Los valores de la pestaña Filtros siguen guardados y vuelven al cambiar de modo.
  Sin Ajustes avanzados, la página única solo muestra el modo y el lugar detectado; marca Ajustes avanzados para editar los contextos.
- **Lugar**: define el tinte, la viñeta y el grano. Orden: mazmorra o banda, interior, clima (lluvia,
  nieve, tormenta de arena) y luego el tipo de zona: tierras templadas, desiertos y tierras áridas,
  tierras nevadas, jungla y pantano, tierras corruptas, tierras volcánicas, bosques arcanos. Una zona
  aún desconocida cuenta como templada. El clima solo cuenta si la Intensidad del clima es superior
  a 0.
- **Hora del día**: define el cielo (día, amanecer y atardecer, noche). La noche sigue el día y la
  noche del juego; el amanecer y el atardecer, la hora del servidor. Sin cielo en interiores ni en
  mazmorras.
- La línea de la derecha muestra el lugar y la hora del día detectados ahora. Cuando una mazmorra,
  un interior o el clima pasan antes que una zona que has ajustado, lo indica.
- **Contexto a editar**: elige un contexto y ajusta sus filtros debajo. El botón Predeterminado
  devuelve el valor incluido para ese contexto.
  El menú tiene cinco grupos: **Zonas** (la zona en la que estás y las que has ajustado), **Mazmorra e interior**, **Clima**, **Tipo de zona** y **Cielo (hora)**.
  Los cuatro primeros ajustan el tinte, la viñeta, el grano y un preajuste gráfico: solo se aplica un lugar a la vez, en el orden indicado arriba.
  El último ajusta el cielo. No hace falta ajustar nada para empezar: cada contexto ya tiene sus valores.
- **Esta zona**: primera opción del mismo menú, con el nombre de la zona en la que estás. Elígela para
  dar a esta zona su propio tinte, viñeta y grano, partiendo de su tipo de zona. Pasa entonces antes
  del tipo de zona, pero después de mazmorra, interior y clima. Las zonas que ajustas siguen en el
  menú. **Tipo de zona** elimina los valores de la zona: vuelve a seguir su tipo de zona.
- **Todas las zonas**: submenú del mismo menú, con todas las zonas conocidas. Elige una para ajustarla sin estar allí. Las zonas están ordenadas por continente.
- **Preajuste** y **Distancia del escenario** (primeras líneas de un lugar o de una zona): se aplican mientras estás en ese lugar, por encima de tus propios ajustes, con el ambiente automático activado o no. La distancia del escenario del lugar va antes que la del preajuste. Tus propios ajustes se conservan y vuelven cuando te vas. **Mis ajustes** no cambia nada. Ejemplo: Bajo en mazmorras, Extra en una zona que te gusta. En una mazmorra o banda, la primera opción del menú ajusta solo esa mazmorra. En la pestaña Calidad, el botón **Por lugar** abre estas líneas para el lugar donde estás; muestra **Aquí: …** mientras un lugar aplica los suyos. En combate, el cambio espera al final del combate.
- **Mi filtro** (primera línea de los filtros de un lugar o de una zona): ese lugar usa uno de tus filtros de la pestaña Mis filtros, con su contraste, su brillo y su gamma, mientras el ambiente automático está activado.
- **Día y noche** (modo **Día y noche automáticos**): Panorama aplica el **Tono diurno** de día y el **Tono nocturno** de
  noche, según el día y la noche del juego. Sustituyen al tono de la pestaña Filtros. El cambio es gradual de 19:00 a 21:00 y de 5:00
  a 7:00 (hora del servidor). Los tonos diurno y nocturno y sus intensidades se definen con Ajustes avanzados.

## 5. Mis filtros

La pestaña Mis filtros (visible con Ajustes avanzados) sirve para crear tantos filtros propios como quieras. **Nuevo** añade uno, **Eliminar** quita el filtro abierto: la pestaña Filtros, los lugares y las zonas que lo usaban vuelven a Ninguno.

- **Filtro a editar**: elige el filtro que ajustan las líneas de abajo. **Nombre**: ponle un nombre (Intro para confirmar).
- **Rojo**, **Verde**, **Azul** (en %): color del tono del filtro. **Intensidad del tono**: su fuerza.
- **Viñeta** y **Grano**: los del filtro.
- **Contraste**, **Brillo**, **Gamma**: ajustes de imagen que el filtro da al juego mientras está aplicado; después vuelven tus propios valores. Mis ajustes: no cambia nada. Según el modo de pantalla, pueden no tener efecto.
- Mientras la pestaña está abierta, el filtro mostrado se ve en directo en el juego.
- Para usar un filtro: elígelo en la línea **Mi filtro** de la pestaña Filtros (en todas partes), o de un lugar o una zona en la pestaña Ambiente (ambiente automático activado). Entonces sustituye el tono, la viñeta y el grano, cuyas líneas quedan en gris. Ninguno: no cambia nada.

## 6. Tus valores y el juego

- En la primera instalación, Panorama lee tus ajustes actuales del juego. No cambia nada hasta que
  muevas un control.
- Un cambio hecho en el menú de Gráficos del juego o con `/console` se muestra en la ventana.
- **Aplicar en cada conexión** (pie, activado por defecto): los ajustes que cambiaste en Panorama se
  escriben de nuevo en cada conexión. Los demás siguen el menú de Gráficos del juego.
- Un cambio hecho durante el combate se aplica cuando termina el combate.
- Algunos ajustes, como MSAA, necesitan reiniciar los gráficos. Haz clic en **Reiniciar** en el pie o
  escribe `/pano restart`. La pantalla parpadea un segundo.

## 7. HDR en Windows

Los ajustes de HDR existen en el juego solo como comandos de consola. Panorama los muestra en la pestaña
**Avanzado**, sección **HDR (solo consola)**. Necesitas un monitor compatible con HDR.

### Paso 1: activar HDR en Windows

Windows 11:

1. Abre **Configuración > Sistema > Pantalla**.
2. Selecciona el monitor HDR si tienes más de uno.
3. Activa **Usar HDR**. El atajo **Win + Alt + B** también lo activa o desactiva.

Windows 10: **Configuración > Sistema > Pantalla > Configuración de color HD de Windows** (Windows HD
Color settings), y luego activa **Reproducir juegos y aplicaciones HDR** (Play HDR games and apps).

Comprueba también que HDR esté activado en el menú propio del monitor, si tiene esa opción.

Desactiva el **HDR automático** (Auto HDR) de Windows 11: **Configuración > Sistema > Pantalla > HDR**. Sirve para juegos sin HDR. WoW genera su propia imagen HDR.

### Paso 2: encontrar el brillo máximo de tu monitor

Instala la aplicación gratuita **Calibración de HDR de Windows** (Windows HDR Calibration) desde la
Microsoft Store y ejecútala. La luminancia máxima que encuentra es el brillo máximo de tu monitor,
en nits.

Sin la aplicación, usa la clasificación HDR del monitor: DisplayHDR 400 significa unos 400 nits,
DisplayHDR 600 unos 600, DisplayHDR 1000 unos 1000.

### Paso 3: configurar HDR en Panorama

Abre `/pano`, pestaña **Avanzado**, sección **HDR (solo consola)**.

1. Marca **Salida HDR**.
2. Marca **Usar brillo máximo** o **Usar brillo de referencia**: uno u otro, nunca los dos. Sin ninguno, la imagen se oscurece.

**Modo de brillo máximo (recomendado)**

- Marca **Usar brillo máximo**.
- Ajusta **Brillo máximo (nits)** al valor encontrado en el paso 2.
- **Intensidad HDR** solo funciona en este modo. El valor predeterminado del juego es 2. Cámbialo en
  pasos pequeños y compara: Blizzard no documenta su efecto exacto.

**Modo de brillo de referencia**

- Marca **Usar brillo de referencia**.
- **Brillo de referencia (nits)** es el brillo del blanco en la escena. 203 es el valor estándar.
  Súbelo si la imagen se ve demasiado oscura en una habitación luminosa. Intensidad HDR no tiene
  efecto en este modo.

Si la imagen no cambia, haz clic en **Reiniciar** en el pie.

### Solución de problemas de HDR

| Problema | Solución |
|---|---|
| Imagen muy oscura | Marca uno de los dos modos de brillo. |
| Imagen gris o deslavada | Activa HDR en Windows (paso 1) y en el menú del monitor. |
| HDR automático activado en Windows | Desactívalo (paso 1). |
| Luces demasiado brillantes o planas | Ajusta el brillo máximo al valor real de tu monitor (paso 2). |
| Quieres desactivar HDR | Desmarca **Salida HDR**. |

Cada línea de HDR tiene un botón Predeterminado que restaura el valor del juego.

## 8. Comandos

| Comando | Acción |
|---|---|
| `/pano` | Abrir o cerrar la ventana |
| `/pano low`, `/pano medium`, `/pano high`, `/pano extra` | Aplicar un preajuste |
| `/pano undo` | Deshacer el último cambio |
| `/pano redo` | Rehacer el cambio que acabas de deshacer |
| `/pano reset` | Devolver cada ajuste y cada filtro a su valor por defecto |
| `/pano status` | Muestra en el chat el lugar y el momento detectados y los filtros aplicados ahora (durante un fundido, los valores de destino) |
| `/pano apply` | Escribir de nuevo los ajustes cambiados en Panorama |
| `/pano restart` | Reiniciar el motor gráfico |
| `/pano minimap` | Mostrar u ocultar el botón del minimapa |

## 9. Restablecer

- El botón **Predeterminado** de cada línea restablece ese ajuste.
- El botón **Predeterminado** del menú de Gráficos del juego restablece solo los ajustes que gestiona
  ese menú, y Panorama lo sigue. Usa los botones Predeterminado de `/pano` para los demás y para los filtros.
- **Restablecer todo** (pie, con confirmación) o `/pano reset`: devuelve cada ajuste cambiado en Panorama
  y cada filtro a su valor por defecto. **Deshacer** lo anula hasta `/reload`.
  La pestaña Ambiente y las zonas ajustadas también se restablecen. Tus filtros de la pestaña Mis filtros también se borran.
