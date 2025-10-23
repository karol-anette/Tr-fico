# main.py
# Escenario con OpenGL + pygame: plano, ejes y un Carro controlable con WASD en el plano XZ.
# Requiere: pygame, PyOpenGL, objloader.py, Carro.py
# Asegúrate de que la ruta al .obj sea correcta (ver constante OBJ_PATH).

import math
import pygame
from pygame.locals import *

from OpenGL.GL import *
from OpenGL.GLU import *

from Carro import Carro

# =========================
# Configuración de ventana
# =========================
SCREEN_WIDTH = 800
SCREEN_HEIGHT = 600

# =========================
# Cámara y proyección
# =========================
FOVY = 60.0
ZNEAR = 0.01
ZFAR = 900.0

# gluLookAt(EYE_X,EYE_Y,EYE_Z,  CENTER_X,CENTER_Y,CENTER_Z,  UP_X,UP_Y,UP_Z)
EYE_X = 300.0
EYE_Y = 200.0
EYE_Z = 300.0
CENTER_X = 0.0
CENTER_Y = 0.0
CENTER_Z = 0.0
UP_X = 0.0
UP_Y = 1.0
UP_Z = 0.0

# =========================
# Ejes y tablero
# =========================
X_MIN, X_MAX = -500.0, 500.0
Y_MIN, Y_MAX = -500.0, 500.0
Z_MIN, Z_MAX = -500.0, 500.0

DimBoard = 200.0  # semilado del plano (el coche se limitará a este rango)

# =========================
# Ruta del modelo del coche
# =========================
# Ajusta esta ruta si tu .obj está en otra carpeta. Debe existir el .mtl y sus texturas asociadas.
OBJ_PATH = "Ejemplo10_objetos/Chevrolet_Camaro_SS_Low.obj"

# =========================
# Control de cámara
# =========================
theta = 0.0
radius = 300.0

# =========================
# Coche y movimiento
# =========================
car_speed = 120.0  # unidades por segundo (delta-time)

# =========================
# Utilidades de dibujo
# =========================
def draw_axes():
    glShadeModel(GL_FLAT)
    glLineWidth(3.0)

    # X - rojo
    glColor3f(1.0, 0.0, 0.0)
    glBegin(GL_LINES)
    glVertex3f(X_MIN, 0.0, 0.0)
    glVertex3f(X_MAX, 0.0, 0.0)
    glEnd()

    # Y - verde
    glColor3f(0.0, 1.0, 0.0)
    glBegin(GL_LINES)
    glVertex3f(0.0, Y_MIN, 0.0)
    glVertex3f(0.0, Y_MAX, 0.0)
    glEnd()

    # Z - azul
    glColor3f(0.0, 0.0, 1.0)
    glBegin(GL_LINES)
    glVertex3f(0.0, 0.0, Z_MIN)
    glVertex3f(0.0, 0.0, Z_MAX)
    glEnd()

    glLineWidth(1.0)

def draw_ground():
    glColor3f(0.3, 0.3, 0.3)
    glBegin(GL_QUADS)
    glVertex3f(-DimBoard, 0.0, -DimBoard)
    glVertex3f(-DimBoard, 0.0,  DimBoard)
    glVertex3f( DimBoard, 0.0,  DimBoard)
    glVertex3f( DimBoard, 0.0, -DimBoard)
    glEnd()

# =========================
# Inicialización OpenGL
# =========================
def init_gl():
    pygame.display.set_caption("OpenGL: Carro (WASD)")
    pygame.display.set_mode((SCREEN_WIDTH, SCREEN_HEIGHT), DOUBLEBUF | OPENGL)

    # Proyección
    glMatrixMode(GL_PROJECTION)
    glLoadIdentity()
    gluPerspective(FOVY, SCREEN_WIDTH / SCREEN_HEIGHT, ZNEAR, ZFAR)

    # Vista/cámara
    glMatrixMode(GL_MODELVIEW)
    glLoadIdentity()
    gluLookAt(EYE_X, EYE_Y, EYE_Z, CENTER_X, CENTER_Y, CENTER_Z, UP_X, UP_Y, UP_Z)

    # Estado
    glClearColor(0, 0, 0, 0)
    glEnable(GL_DEPTH_TEST)
    glPolygonMode(GL_FRONT_AND_BACK, GL_FILL)

    # Luces básicas
    glEnable(GL_LIGHTING)
    glEnable(GL_LIGHT0)
    glEnable(GL_COLOR_MATERIAL)

    # Luz direccional desde arriba
    light_pos = (0.0, 200.0, 0.0, 0.0)
    glLightfv(GL_LIGHT0, GL_POSITION,  light_pos)
    glLightfv(GL_LIGHT0, GL_AMBIENT,   (0.5, 0.5, 0.5, 1.0))
    glLightfv(GL_LIGHT0, GL_DIFFUSE,   (0.5, 0.5, 0.5, 1.0))

# =========================
# Cámara orbital con flechas
# =========================
def update_camera_orbit():
    global EYE_X, EYE_Z
    EYE_X = radius * (math.cos(math.radians(theta)) + math.sin(math.radians(theta)))
    EYE_Z = radius * (-math.sin(math.radians(theta)) + math.cos(math.radians(theta)))
    glLoadIdentity()
    gluLookAt(EYE_X, EYE_Y, EYE_Z, CENTER_X, CENTER_Y, CENTER_Z, UP_X, UP_Y, UP_Z)

# =========================
# Render del frame
# =========================
def render_frame(carro: Carro):
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
    draw_axes()
    draw_ground()
    carro.draw()

# =========================
# Programa principal
# =========================
def main():
    pygame.init()
    init_gl()

    # Instanciar el coche
    carro = Carro(
        obj_path=OBJ_PATH,
        swapyz=True,          # corrige ejes del modelo
        scale=10.0,           # escala del modelo
        offset_z_model=15.0   # corrección local (depende del .obj)
    )
    carro.set_position(0.0, 0.0)

    clock = pygame.time.Clock()
    running = True

    global theta

    while running:
        # Eventos puntuales
        for event in pygame.event.get():
            if event.type == QUIT:
                running = False
            if event.type == KEYDOWN and event.key == K_ESCAPE:
                running = False

        # Teclado continuo
        keys = pygame.key.get_pressed()

        # Cámara orbital con flechas (igual que antes)
        if keys[K_RIGHT]:
            theta = 0.0 if theta > 359.0 else theta + 1.0
            update_camera_orbit()
        if keys[K_LEFT]:
            theta = 360.0 if theta < 1.0 else theta - 1.0
            update_camera_orbit()

        # Delta-time y movimiento del coche con WASD
        dt = clock.tick(60) / 1000.0  # segundos
        move = car_speed * dt

        dx = 0.0
        dz = 0.0
        # Convención: W = +Z (adelante)
        if keys[K_w]:
            dz += move
        if keys[K_s]:
            dz -= move
        if keys[K_a]:
            dx -= move
        if keys[K_d]:
            dx += move

        # Clamping a los límites del tablero
        bounds = (-DimBoard, DimBoard, -DimBoard, DimBoard)
        carro.move(dx, dz, bounds=bounds)

        # Dibujar
        render_frame(carro)
        pygame.display.flip()

    pygame.quit()

if __name__ == "__main__":
    main()
