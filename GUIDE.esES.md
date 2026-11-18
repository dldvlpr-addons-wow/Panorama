# Guía de Panorama

Cómo usar Panorama en WoW Forever y cómo configurar HDR en Windows.

## 1. Abrir la ventana

- Escribe `/pano` o haz clic izquierdo en el botón de Panorama del minimapa.
- En Opciones > AddOns > Panorama también hay un botón que la abre.
- Arrastra la barra de título para mover la ventana. Escape o el botón de cierre la cierra.

El botón del minimapa:

- El clic izquierdo abre o cierra la ventana.
- El clic derecho muestra los preajustes, deshacer y el reinicio de los gráficos.
- Arrástralo para moverlo alrededor del minimapa. `/pano minimap` lo muestra u oculta.

## 2. La ventana

| Parte | Qué hace |
|---|---|
| Cuadro de búsqueda (arriba a la derecha) | Escribe una palabra para listar los ajustes que coinciden de todas las pestañas. Bórrala para volver. |
| Pestañas | Calidad, Filtros, Interfaz, Avanzado. Se recuerda la pestaña abierta. |
| Selector de idioma (a la derecha de las pestañas) | Idioma del juego o uno de diez idiomas. Al cambiarlo se recarga la interfaz. |
| Guía (a la izquierda del selector de idioma) | Abre esta guía en el juego. |
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
  sin niebla volumétrica, la intensidad del tono sin un tono).
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

¿Has cambiado de opinión? **Deshacer el último preajuste** (botón junto a los preajustes, o `/pano undo`)
restaura los ajustes de antes del último preajuste.

## 4. Filtros

La pestaña Filtros añade efectos sobre la imagen. No cambian ningún ajuste del juego.

- **Tono**: haz clic en una miniatura para aplicarlo al instante (Sepia, Cálido, Frío, Noche, Esmeralda,
  Crepúsculo). **Intensidad del tono** define su fuerza.
- **Viñeta**: oscurece los bordes de la pantalla.
- **Grano**: grano animado.
- **Barras negras**: barras superior e inferior, de 0 a 20 % de la pantalla cada una. El juego sigue
  renderizando lo que ocultan, así que no aumentan la tasa de fotogramas.

## 5. Tus valores y el juego

- En la primera instalación, Panorama lee tus ajustes actuales del juego. No cambia nada hasta que
  muevas un control.
- Un cambio hecho en el menú de Gráficos del juego o con `/console` se muestra en la ventana.
- **Aplicar en cada conexión** (pie, activado por defecto): los ajustes que cambiaste en Panorama se
  escriben de nuevo en cada conexión. Los demás siguen el menú de Gráficos del juego.
- Un cambio hecho durante el combate se aplica cuando termina el combate.
- Algunos ajustes, como MSAA, necesitan reiniciar los gráficos. Haz clic en **Reiniciar** en el pie o
  escribe `/pano restart`. La pantalla parpadea un segundo.

## 6. HDR en Windows

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

## 7. Comandos

| Comando | Acción |
|---|---|
| `/pano` | Abrir o cerrar la ventana |
| `/pano low`, `/pano medium`, `/pano high`, `/pano extra` | Aplicar un preajuste |
| `/pano undo` | Restaurar los ajustes de antes del último preajuste |
| `/pano reset` | Devolver cada ajuste y cada filtro a su valor por defecto |
| `/pano apply` | Escribir de nuevo los ajustes cambiados en Panorama |
| `/pano restart` | Reiniciar el motor gráfico |
| `/pano minimap` | Mostrar u ocultar el botón del minimapa |

## 8. Restablecer

- El botón **Predeterminado** de cada línea restablece ese ajuste.
- El botón **Predeterminado** del menú de Gráficos del juego restablece solo los ajustes que gestiona
  ese menú, y Panorama lo sigue. Usa los botones Predeterminado de `/pano` para los demás y para los filtros.
- **Restablecer todo** (pie, con confirmación) o `/pano reset`: devuelve cada ajuste cambiado en Panorama
  y cada filtro a su valor por defecto. No se puede deshacer.
