import scala.annotation.tailrec

import org.lwjgl.input.Keyboard
import org.lwjgl.opengl.Display
import org.lwjgl.opengl.DisplayMode
import org.lwjgl.opengl.GL11

object Engine {
  def create(): Unit = {
    Display.setDisplayMode(new DisplayMode(800, 600))
    Display.create()
    GL11.glMatrixMode(GL11.GL_PROJECTION)
    GL11.glLoadIdentity()
    GL11.glOrtho(0, 800, 0, 600, 1, -1)
    GL11.glMatrixMode(GL11.GL_MODELVIEW)
  }

  def destroy(): Unit = {
    Display.destroy()
  }

  def startRender(): Unit = {
    // Clear the screen and depth buffer
    GL11.glClear(GL11.GL_COLOR_BUFFER_BIT | GL11.GL_DEPTH_BUFFER_BIT)
  }

  def rectangle(x: Int, y: Int): Unit = {
    // set the color of the quad (R,G,B,A)
    GL11.glColor3f(0.5f, 0.5f, 1.0f)

    // draw quad
    GL11.glBegin(GL11.GL_QUADS)
    GL11.glVertex2f(x, y)
    GL11.glVertex2f(x + 200, y)
    GL11.glVertex2f(x + 200, y + 200)
    GL11.glVertex2f(x, y + 200)
    GL11.glEnd()
  }

  def endRender(): Unit = {
    Display.update()
  }

  def readInput(): Option[Option[Int]] = {
    Display.sync(30)
    if (Display.isCloseRequested) None
    else if (Keyboard.next()) Option(Option(Keyboard.getEventKey()))
    else Option(None)
  }
}

class World(val x: Int, val y: Int) {
  def this() = this(0, 0)

  def step(key: Option[Int]): World = {
    key match {
      case Some(key) => {
        key match {
          case Keyboard.KEY_UP => new World(x, y + 1)
        }
      }
      case None => this
    }
  }

  def render(): Unit = {
    Engine.startRender()
    Engine.rectangle(x, y)
    Engine.endRender()
  }
}

object Hello extends App {
  Engine.create()

  loop(new World())

  Engine.destroy()

  @tailrec def loop(world: World): Unit = {
    Engine.readInput() match {
      case Some(key) => {
        val newWorld = world.step(key)
        newWorld.render()
        loop(newWorld) // out with the old, in with the new
      }
      case None => Unit
    }
  }

}

