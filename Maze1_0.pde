
int w = 20;
int h = 20;
int sf = 20;
MazeMaker maze;
int c = 0;
boolean path = false;
boolean game = true;
int currx;
int curry;
int finishx = (int) (Math.random() * w);
int finishy = (int) (Math.random() * h);
boolean finish = false;

void setup() {
  size(410, 410);
  drawMaze();
  strokeWeight(1);
  if(game) {
    currx = (int) (Math.random() * w);
    curry = (int) (Math.random() * h);
  }
}

void drawMaze() {
  maze = new MazeMaker(w, h);
  boolean[] curr = maze.getWalls(0,0);
  strokeWeight(2);
  noFill();
  stroke(0,0,0);
  for (int i = 0; i < w * sf; i += sf) {
    for (int j = 0; j < h * sf; j += sf) {
      //i, j are current x, y
      curr = maze.getWalls(i / sf, j / sf);
      //now we draw!, we only have to draw the south and east walls!
      if (i == 0) {
        line(5, j + 5, 5, j + sf + 5);
      }
      if (j == 0) {
        line(i + 5, 5, i + sf + 5, 0 + 5);
      }
      if (!curr[2]) {
        line(i + sf + 5, j + 5, i + sf + 5, j + sf + 5);
      }
      
      if (!curr[3]) {
        line(i + 5, j + sf + 5, i + sf + 5, j + sf + 5);
      }
    }
  }
  if(game) {
    stroke(0,0,0);
    fill(40,40,40);
    square(finishx * sf + 7, finishy * sf + 7, 16);
  }
  saveFrame("maze.jpg");
}

void draw() { //<>//
  if (finish) {
    background(200, 200, 200);
    textSize(64);
    text("YOU WIN!", w * sf/4, h * sf/2);
  } else {
    if (c < w * h && !keyPressed && path) {
      //PImage img = loadImage("maze.jpg");
      //background(img);
      int x = maze.path[c][0] * sf + 5;
      int y = maze.path[c][1] * sf + 5;
      float d = c;
      fill(127.5 * sin(d/255.0) + 127.5, 127.5 * sin((d - 510.0)/255.0) + 127.5, 127.5 * sin((d - 1020.0)/255.0)+ 127.5);
      square(x, y, 20);
      c++; 
    }
    if (game) {
      PImage img = loadImage("maze.jpg");
      background(img);
      float d = c;
      fill(127.5 * sin(d/255.0) + 127.5, 127.5 * sin((d - 510.0)/255.0) + 127.5, 127.5 * sin((d - 1020.0)/255.0)+ 127.5);
      //draw square
      square(currx * sf + 7, curry * sf + 7, 16);
      if (currx == finishx && curry == finishy) {
        finish = true;
      }
      c++; 
    }  
  }
}

void keyReleased() {
  if (game) {
    if ((key == 'w' || key == 'W') && maze.getWalls(currx, curry)[1]) {
      curry -= 1;
    } else if ((key == 'a'|| key == 'A') && maze.getWalls(currx, curry)[4]) {
      currx -= 1;
    } else if ((key == 's'|| key == 'S') && maze.getWalls(currx, curry)[3]) {
      curry += 1;
    } else if ((key == 'd'|| key == 'D') && maze.getWalls(currx, curry)[2]) {
      currx += 1; 
    } 
  }
}





public class MazeMaker {

    // value at [x][y][0] - 1 if visted already, 0 if not
    // value at [x][y][1] - 1 if North (-y) wall has been removed, 0 if not.
    // value at [x][y][2] - 1 if East wall(+x) has been removed, 0 if not.
    // value at [x][y][3] - 1 if South wall(+y) has been removed, 0 if not.
    // value at [x][y][4] - 1 if West wall(-x) has been removed, 0 if not.
    private boolean[][][] walls; 
    public int[][] path;
    private int count;
    private int width;
    private int height;

    

    public MazeMaker(int w, int h) {
        walls = new boolean[w][h][5];//initialized to be all zeroes
        path = new int[w * h][2];
        count  = 0;
        this.width = w;
        this.height = h;
      
        fill(204, 102, 0);
        maker((int) (Math.random() * w), (int) (Math.random() * h)); //pick random starting node
    }

    private void maker(int x, int y) {
        walls[x][y][0] = true;
        path[count][0] = x;
        path[count][1] = y;
        count++;
        //square(x * sf, y * sf, 40);
        int[] neighbors = getUnvisitedNeighbors(x, y);

        //while we have unvisited neighbors, pick a random one
        while (neighbors[0] != 0) {
            int dir = (int)(Math.random() * 4) + 1;

            while (neighbors[dir] == 0) {
                //if the neighbor is visited, go to next unvisited.
                dir = (dir + 1) % 5; 
                if ( dir == 0) {
                  dir = 1;
                }
            }
            
            //set the direction as having a removed wall.
            walls[x][y][dir] = true;
            //set the future spot as also having removed the wall in that direction,
            //then call maker there
            switch(dir) {
                case 1: walls[x][y - 1][3] = true;
                    maker(x, y - 1);
                    break;
                case 2: walls[x + 1][y][4] = true;
                    maker(x + 1, y);
                    break;
                case 3: walls[x][y + 1][1] = true;
                    maker(x, y + 1);
                    break;
                case 4: walls[x - 1][y][2] = true;
                    maker(x - 1, y);
                    break;
            }

            neighbors = getUnvisitedNeighbors(x, y);  
        }    
    }

    // returns int[] where:
    // -        ret[0] is number of unvisited neighbors
    // -        ret[1] is 1 if north is unvisited
    // -        ret[2] is 1 if east is unvisited
    // -        ret[3] is 1 if south is unvisited
    // -        ret[4] is 1 if west is unvisited

    private int[] getUnvisitedNeighbors(int x, int y) {
        int[] ret = new int[5];

        // think this is good.
        ret[1] = ((y - 1 < 0) || (walls[x][y - 1][0])) ? 0 : 1;
        ret[2] = ((x + 1 >= width) || (walls[x + 1][y][0])) ? 0 : 1;
        ret[3] = ((y + 1 >= height) || (walls[x][y + 1][0])) ? 0 : 1;
        ret[4] = ((x - 1 < 0) || (walls[x - 1][y][0])) ? 0 : 1;
        //count the unvisited
        for(int i = 1; i < 5; i++) {
            ret[0] += ret[i];
        }
        return ret;
    }
    
    public boolean[] getWalls(int x, int y) {
        return walls[x][y];
    }

}
