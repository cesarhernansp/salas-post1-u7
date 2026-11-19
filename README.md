# salas-post1-u7

## Descripción

Laboratorio de la Unidad 7 de Arquitectura de Computadores (post-contenido): manejo de pantalla y teclado en NASM, ejecutado sobre DOSBox, en un único repositorio.

- **Estudiante:** Cesar Hernan Salas Peñaranda (cuenta de GitHub `cesarhernansp`)
- **Parte 1:** salida de texto con `INT 21h` y control de pantalla con `INT 10h` (cursor, color, cadenas en posición exacta), más la consulta del modo de video (`AH=0Fh`) y la relectura de una celda (`AH=08h`).
- **Parte 2:** lectura de teclado con `INT 16h` (scan codes y byte de estado `AH=02h`) y escritura directa en el segmento de video `B800h`, con un mini editor y un indicador de Shift/Ctrl en tiempo real.

## Entorno de trabajo

| Componente | Versión / detalle |
|---|---|
| Sistema anfitrión | Windows 11 Home, 16 GB de RAM |
| Emulador | DOSBox 0.74-3 |
| Ensamblador | NASM 3.02 para DOS (`nasm.exe`, requiere el host DPMI `cwsdpmi.exe`) |
| Editor | VS Code / editor de texto plano; archivos `.asm` en ASCII sin BOM |

`nasm.exe` y `cwsdpmi.exe` se copian a la raíz del proyecto (que se monta como `C:\`), pero no se versionan por ser binarios de terceros.

## Compilación y ejecución

```
Z:\> mount C C:\Users\Cesar\salas-post1-u7
Z:\> C:
C:\> cwsdpmi -p
C:\> nasm -f bin post1.asm -o post1.com
C:\> post1.com
```

La misma secuencia se aplica a cada programa (`post1b`, `post1c`, `post1d`, `post2a`, `post2b`, `post2c`, `post2d`, `post2e`). Todos los nombres respetan el formato 8.3 de DOS.

## Capturas

Las capturas de `capturas/` son imágenes de la ventana de DOSBox (o de la consola de Windows) tal como se obtuvieron, sin recortes, ampliaciones ni retoques.
