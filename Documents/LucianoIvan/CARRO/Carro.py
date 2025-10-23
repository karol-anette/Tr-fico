# Carro.py
# Clase Carro: carga un modelo .OBJ y lo dibuja/mueve en el plano XZ.

from OpenGL.GL import *
from objloader import OBJ

class Carro:
    """
    Carro controlable en el plano XZ (sin rotación).
    - Usa objloader.OBJ para cargar el modelo .obj
    - Mantiene posición (x, z), altura fija (y=0)
    - Se dibuja con correcciones de ejes/escala para este modelo en particular
    """

    def __init__(self, obj_path: str, swapyz: bool = True, scale: float = 10.0, offset_z_model: float = 15.0):
        """
        :param obj_path: Ruta al archivo .obj del coche
        :param swapyz:   True para intercambiar ejes Y/Z del modelo si es necesario
        :param scale:    Escala del modelo al dibujar
        :param offset_z_model: Traslación local en Z para asentar el coche
        """
        self.obj = OBJ(obj_path, swapyz=swapyz)
        # Si no generó display list en __init__, puedes llamar self.obj.generate(), pero por defecto ya lo hace.
        self.scale = scale
        self.offset_z_model = offset_z_model

        # Posición en el mundo (XZ). Altura fija (y=0).
        self.x = 0.0
        self.z = 0.0
        self.y = 0.0  # por si en el futuro quieres levantarlo ligeramente

    def set_position(self, x: float, z: float):
        self.x = float(x)
        self.z = float(z)

    def move(self, dx: float, dz: float, bounds=None):
        """
        Mueve el coche y opcionalmente ajusta a límites.
        :param dx: delta X
        :param dz: delta Z
        :param bounds: tuple (min_x, max_x, min_z, max_z) para clamping
        """
        self.x += dx
        self.z += dz

        if bounds is not None:
            min_x, max_x, min_z, max_z = bounds
            if self.x < min_x: self.x = min_x
            if self.x > max_x: self.x = max_x
            if self.z < min_z: self.z = min_z
            if self.z > max_z: self.z = max_z

    def draw(self):
        """
        Dibuja el coche aplicando:
        - Traslación mundial (x, y, z)
        - Rotación -90° sobre X para alinear el .obj al plano XZ
        - Traslación local en Z para corregir pivote del modelo
        - Escala del modelo
        """
        glPushMatrix()
        # Posición en el mundo
        glTranslatef(self.x, self.y, self.z)

        # Correcciones orientadas a este .obj (ajústalas si cambias de modelo):
        glRotatef(-90.0, 1.0, 0.0, 0.0)    # Colocar el modelo en el plano XZ
        glTranslatef(0.0, 0.0, self.offset_z_model)
        glScalef(self.scale, self.scale, self.scale)

        # Render del display list del OBJ
        self.obj.render()
        glPopMatrix()
