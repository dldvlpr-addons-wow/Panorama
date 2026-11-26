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
| **Simple**, **Avanzado** (junto al título) | Simple: cada pestaña muestra una lista corta de los ajustes principales, sin secciones. Avanzado: todos los ajustes, por secciones, con las reglas por lugar y la sección Expertos. En la primera instalación es Simple; si ya usabas Panorama, es Avanzado. La búsqueda siempre encuentra todos los ajustes. |
| Guía (arriba a la derecha) | Abre esta guía en el juego. |
| Menú **Opciones** (arriba a la derecha) | **Idioma** (idioma del juego o uno de diez idiomas; al cambiarlo se recarga la interfaz), **Aplicar en cada conexión**, **Botón del minimapa**, **Restablecer todo…**. |
| **Aspecto actual:** (barra bajo el título) | El aspecto que hay ahora sobre el mundo y quién lo fija: tú, Día y noche o el lugar. Su botón (**Editar**, **Editar esta regla**) abre dónde cambiarlo. Pasa el ratón por la barra para ver cuál va primero. |
| Pestañas | **Imagen** (calidad gráfica), **HDR**, **Ambiente** (aspecto del mundo), **Mis filtros**. Se recuerda la pestaña abierta. |
| Cuadro de búsqueda (a la derecha de las pestañas) | Escribe una palabra para listar los ajustes que coinciden de todas las pestañas. Bórrala para volver. |
| Preajustes (pestaña Imagen) | Bajo, Medio, Alto, Extra. Se resalta el preajuste que coincide con tus ajustes. |
| Pie | **Deshacer** anula tu último cambio: control deslizante, casilla, preajuste, filtro, ambiente o Restablecer todo. **Rehacer** lo recupera. Los últimos 20 cambios se conservan hasta `/reload`. **Reiniciar** reinicia el motor gráfico. |

En el modo Avanzado, haz clic en el título de una sección para plegarla o desplegarla. La sección **Expertos (solo consola)** empieza
plegada. El título de una sección indica cuántos de sus ajustes has cambiado.

### Una línea de ajuste

- **Control deslizante**: el valor se escribe al soltar el botón del ratón, no mientras arrastras.
- **Cuadro de valor** junto al control deslizante: escribe un valor y pulsa Intro o haz clic en otro sitio.
  Escape cancela, Tab pasa al cuadro siguiente. La coma sirve como separador decimal. El valor se mantiene
  dentro del rango del control deslizante.
- **Botón Predeterminado**: devuelve ese ajuste a su valor predeterminado. Pasa el ratón por encima para
  ver el valor.
- **Marca dorada** a la izquierda: has cambiado este ajuste.
- **Menú del juego**: cuando un menú del juego también establece este valor, la ayuda de la etiqueta lo nombra. Ese menú
  no vuelve a leer el valor, así que puede mostrar otro nivel.
- **Línea en gris**: depende de otro ajuste que está desactivado (por ejemplo, **Calidad de la niebla volumétrica**
  sin **Niebla volumétrica**, la intensidad del tono sin un tono), o un modo la fija. Pasa el ratón por la etiqueta para ver el motivo.
  Una línea que depende de otra aparece desplazada a la derecha, justo debajo de ella.
- Pasa el ratón por una etiqueta para leer su ayuda completa.

## 3. Preajustes

| Preajuste | Resultado |
|---|---|
| Bajo | Máximo rendimiento. Poca distancia de visión, sin sombras. |
| Medio | Equilibrado. Buen rendimiento y sombras correctas. |
| Alto | Nivel Alto del juego. Sombras completas, todos los efectos. |
| Extra | Alto, con la mayor distancia de visión. |

Los preajustes solo cambian los ajustes de calidad gráfica de la pestaña Imagen. No tocan la cámara,
el ratón, la interfaz, el enfoque, la baja latencia, HDR ni los filtros.

¿Has cambiado de opinión? **Deshacer** (pie, o `/pano undo`)
restaura los ajustes de antes del preajuste.

## 4. Ambiente

La pestaña Ambiente define el aspecto del mundo: efectos sobre la imagen. No cambian ningún ajuste del juego.

- **Modo** (parte superior de la pestaña): **Fijo** (el mismo filtro en todas partes), **Día y noche** (un tono
  diurno y un tono nocturno) o **Según el lugar** (ver más abajo). Fijo por defecto.
- **Aquí**: el lugar y la hora del día detectados ahora. Cuando una mazmorra, un interior o el clima pasan antes
  que una zona que has ajustado, lo indica.
- **Filtro** (modos Fijo y Día y noche): **Base** usa las líneas de abajo. Uno de tus filtros
  (pestaña Mis filtros) sustituye el tono, la viñeta y el grano, y aporta su contraste,
  su brillo y su gamma. **Editar filtro** lo abre en la pestaña Mis filtros.
- **Tono**: haz clic en una miniatura para aplicarlo al instante (Sepia, Cálido, Frío, Noche, Esmeralda,
  Crepúsculo). **Intensidad del tono** define su fuerza.
- **Viñeta**: oscurece los bordes de la pantalla.
- **Grano**: grano animado.
- **Tono diurno** y **Tono nocturno** (modo Día y noche): Panorama aplica el tono diurno de día y el tono nocturno de
  noche, según el día y la noche del juego. Sustituyen al tono. El cambio es gradual de 19:00 a 21:00 y de 5:00
  a 7:00 (hora del servidor). Uno de tus filtros elegido en la línea Filtro los sustituye.
- **Cielo**: los mismos colores en degradado, completos arriba de la pantalla y más claros abajo.
  **Intensidad del cielo** define su fuerza.
- **Barras negras**: barras superior e inferior, de 0 a 20 % de la pantalla cada una, en todos los modos. El juego sigue
  renderizando lo que ocultan, así que no aumentan la tasa de fotogramas.

En el modo Simple, la pestaña muestra el modo, el lugar, el filtro, el tono y su intensidad, y los
tonos diurno y nocturno. La viñeta, el grano, el cielo y las barras negras están en el modo Avanzado.

### Según el lugar

En el modo **Según el lugar**, el tinte, el cielo, la viñeta y el grano cambian solos según dónde estés.

- Las líneas del modo Fijo se ocultan: la regla del lugar las sustituye. Solo quedan las barras negras.
  Sus valores siguen guardados y vuelven al cambiar de modo.
  En el modo Simple se aplican las reglas incluidas; elige Avanzado para editarlas.
- **Lugar**: define el tinte, la viñeta y el grano. Orden: mazmorra o banda, interior, clima (lluvia,
  nieve, tormenta de arena) y luego el tipo de zona: tierras templadas, desiertos y tierras áridas,
  tierras nevadas, jungla y pantano, tierras corruptas, tierras volcánicas, bosques arcanos. Una zona
  aún desconocida cuenta como templada. El clima solo cuenta si la Intensidad del clima es superior
  a 0.
- **Hora del día**: define el cielo (día, amanecer y atardecer, noche). La noche sigue el día y la
  noche del juego; el amanecer y el atardecer, la hora del servidor. Sin cielo en interiores ni en
  mazmorras.
- **Regla** (modo Avanzado): elige una regla y ajústala debajo. El botón Predeterminado
  devuelve el valor incluido para esa regla. La primera vez que se abre la ventana, se abre la regla del lugar en el que estás.
  El menú tiene cinco grupos: **Zonas** (la zona en la que estás y las que has ajustado), **Mazmorra e interior**, **Clima**, **Tipo de zona** y **Cielo (hora)**.
  Los cuatro primeros ajustan el tinte, la viñeta, el grano y un preajuste gráfico: solo se aplica un lugar a la vez, en el orden indicado arriba.
  El último ajusta el cielo. No hace falta ajustar nada para empezar: cada regla ya tiene sus valores.
- **Esta zona**: primera opción del mismo menú, con el nombre de la zona en la que estás. Elígela para
  dar a esta zona su propio tinte, viñeta y grano, partiendo de su tipo de zona. Pasa entonces antes
  del tipo de zona, pero después de mazmorra, interior y clima. Las zonas que ajustas siguen en el
  menú. **Volver al tipo de zona** (junto al menú) elimina los valores de la zona: vuelve a seguir su tipo de zona.
- **Todas las zonas**: submenú del mismo menú, con todas las zonas conocidas. Elige una para ajustarla sin estar allí. Las zonas están ordenadas por continente.
- **Preajuste** y **Distancia del escenario** (sección **Imagen** de un lugar o de una zona): se aplican mientras estás en ese lugar, por encima de tus propios ajustes, sea cual sea el modo de ambiente. La distancia del escenario del lugar va antes que la del preajuste. Tus propios ajustes se conservan y vuelven cuando te vas. **Mis ajustes** no cambia nada. Ejemplo: Bajo en mazmorras, Extra en una zona que te gusta. En una mazmorra o banda, la primera opción del menú ajusta solo esa mazmorra. En la pestaña Imagen, **Aquí: …** aparece junto a los preajustes mientras un lugar aplica los suyos; en el modo Avanzado, abre esa regla. En combate, el cambio espera al final del combate.
- **Filtro** (primera línea de la sección **Aspecto** de un lugar o de una zona): ese lugar usa uno de tus filtros de la pestaña Mis filtros, con su contraste, su brillo y su gamma. **Ajustes de abajo**: el tinte, la viñeta y el grano de la regla. La sección Aspecto solo se aplica en el modo Según el lugar.

## 5. Mis filtros

La pestaña Mis filtros sirve para crear tantos filtros propios como quieras. El filtro abierto solo se muestra en el mundo en vista previa; el que se aplica se elige en la pestaña Ambiente. **Nuevo** añade uno y lo abre, **Eliminar** quita el filtro abierto: el filtro de la pestaña Ambiente y las reglas que lo usaban vuelven a no tener filtro. Siempre queda un filtro.

- **Filtro**: elige el filtro que ajustan las líneas de abajo. **Nombre**: ponle un nombre (Intro para confirmar).
- **Tono**: haz clic en una miniatura para dar ese color al filtro. **Rojo**, **Verde**, **Azul** (en %): su color exacto. **Intensidad del tono**: su fuerza.
- **Viñeta** y **Grano**: los del filtro.
- **Contraste**, **Brillo**, **Gamma**: ajustes de imagen que el filtro da al juego mientras está aplicado; después vuelven tus propios valores. Mis ajustes: no cambia nada. Según el modo de pantalla, pueden no tener efecto.
- En el modo Simple, la pestaña solo muestra el tono y la intensidad del tono.
- Mientras la pestaña está abierta, el filtro mostrado se ve en directo en el juego. La barra **Aspecto actual:** indica cuándo es solo una vista previa.
- Para usar un filtro: elígelo en la línea **Filtro** de la pestaña Ambiente (modos Fijo y Día y noche), o de un lugar o una zona (modo Según el lugar). Entonces sustituye el tono, la viñeta y el grano. **Base** o **Ajustes de abajo**: no cambia nada.

## 6. Tus valores y el juego

- En la primera instalación, Panorama lee tus ajustes actuales del juego. No cambia nada hasta que
  muevas un control.
- Un cambio hecho en el menú de Gráficos del juego o con `/console` se muestra en la ventana.
- **Aplicar en cada conexión** (menú Opciones, activado por defecto): los ajustes que cambiaste en Panorama se
  escriben de nuevo en cada conexión. Los demás siguen el menú de Gráficos del juego.
- Un cambio hecho durante el combate se aplica cuando termina el combate.
- Algunos ajustes, como MSAA, necesitan reiniciar los gráficos. Haz clic en **Reiniciar** en el pie o
  escribe `/pano restart`. La pantalla parpadea un segundo.

## 7. HDR en Windows

Los ajustes de HDR existen en el juego solo como comandos de consola. Panorama los muestra en la pestaña
**HDR**. Necesitas un monitor compatible con HDR.

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

Abre `/pano`, pestaña **HDR**. En el modo Simple, la pestaña solo muestra las tres primeras líneas de abajo: elige
**Avanzado** para ver **Intensidad HDR** y el brillo de referencia.

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
| `/pano blackbars 10` | Bandas negras al 10 % de la altura de la pantalla (0 a 20). `off` las quita |
| `/pano grain 10` | Grano a 10 (0 a 100). `off` lo quita |
| `/pano vignette 10` | Viñeta a 10 (0 a 100). `off` la quita |

## 9. Restablecer

- El botón **Predeterminado** de cada línea restablece ese ajuste.
- El botón **Predeterminado** del menú de Gráficos del juego restablece solo los ajustes que gestiona
  ese menú, y Panorama lo sigue. Usa los botones Predeterminado de `/pano` para los demás y para los filtros.
- **Restablecer todo…** (menú Opciones, con confirmación) o `/pano reset`: devuelve cada ajuste cambiado en Panorama
  y cada filtro a su valor por defecto. **Deshacer** lo anula hasta `/reload`.
  La pestaña Ambiente y las zonas ajustadas también se restablecen. Tus filtros de la pestaña Mis filtros también se borran.
