import java.lang.Thread;


Markov thread1;
boolean saved;

void setup(){
  size(700, 700);
  background(255);
  setup_markov();
  thread1 = new Markov();
  thread1.start();
}

void draw(){
  strokeWeight(5);

  for(int t = 1; t <= single.obs_length; t++)
    for(int x = 0; x < single.state_length; x++){
      int red_c = (int) map(log(visited[t][x]), 0, log(max_visits), 0, 255);
      int grn_c = (int) map(log(visited[t][x]), 0, log(max_visits), 102, 0);
      int blu_c = (int) map(log(visited[t][x]), 0, log(max_visits), 204, 0);
      
      noFill();
      stroke(red_c, grn_c, blu_c);

      ellipse(map(t, 0, single.obs_length + 1, 0, width),
	      map(x+1, 0, single.state_length + 1, height, 0), 45, 45);

      fill(red_c, grn_c, blu_c);
      textSize(19);
      textAlign(CENTER);
      text("" + visited[t][x], 
	   map(t, 0, single.obs_length + 1, 0, width) - 32.5,
	   map(x+1, 0, single.state_length + 1, height, 0) - 45 - 22.5, 65, 65);
      
    }

  if(thread1.done() && !saved){
    save("out.png");
    saved = true;
    println("saved.");
  }
}

void setup_markov(){
  single = new MarkovModel();
  single.state_length = 5;
  single.obs_length = 7;
  visited = new int[single.obs_length + 1][single.state_length];
  single.memoizing = true;
  single.MU = new float[] {0.3, 0.5, 0.6, 0.6, 0.9};
  single.SIGMA = new float[] {.1, .1, .2, .1, .1};
  single.OBS = new float[] {.3, 0, .1, .1, .2, .7, .4, .6, .6, .5};
  single.A = new float[][]
    {{ .2, .3, .1, .3, .1 },
     { .1, .6, .1, .1, .1},
     { .1, .1, .6, .1, .1},
     { .1, .1, .1, .6, .1},
     { .2, .2, .2, .2, .2}};
  single.PI = new float[] {.2, .2, .2, .2, .2};
  
  // finally, initialize the memoization matrix
  if(single.memoizing){
    single.memoized = new float[single.obs_length+1][single.state_length];
    for(int t = 0; t <= single.obs_length; t++)
      for(int x = 0; x < single.state_length; x++)
	single.memoized[t][x] = -1;
  }
}
int[][] visited;
int max_visits = 0;
int cur_t;
int cur_k;

class MarkovModel{
  public float[][] A;
  public float[] MU, SIGMA, PI, OBS;
  public int state_length, obs_length;
  public boolean memoizing = false;
  public float[][] memoized;
}

MarkovModel single;

float p(float x, int k){
  float p1 = exp(-0.5 * pow(x - single.MU[k], 2) / pow(single.SIGMA[k], 2));
  float p2 = single.SIGMA[k] * sqrt(TAU);
  return p1 / p2;
}

float pi(int k){
  return single.PI[k];
}

float obs(int t){
  return single.OBS[t];
}

float transition(int k, int k_prime){
  return single.A[k][k_prime];
}

int states(){
  return single.state_length;
}

class Markov extends Thread{
  boolean done = false;
  boolean done(){
    return done;
  }
  void run(){
    // now, run the algo.
    println("Go!");
    float max = -1;
    for(int x = 0; x < single.state_length; x++){
      float cur = p_observations_to_state(single.obs_length, x);
      if (cur > max)
	max = cur;
    }
    done = true;
  }

  void visit(int t, int k){
    visited[t][k]++;
    if(visited[t][k] > max_visits){
      max_visits = visited[t][k];
    }
    cur_t = t;
    cur_k = k;
  }

  float p_observations_to_state(int t, int k){
    /*
      P_observations_to_state (V_t_k)
      :=  P(the most probable sequence for t observations
      which arrive at state k)
    */
    
    visit(t, k);

    if(single.memoizing && single.memoized[t][k] != -1){
      return single.memoized[t][k];
    }
    
    float ret;
    if(t == 1){
      // base case
      ret =  p(obs(0), k) * pi(k);
    }else{
      // recursion
      float max_p_rec = -1;
      for(int x = 0; x < states(); x++){
	float p_x_to_k = transition(x, k) * p_observations_to_state(t-1, x);
	if(p_x_to_k > max_p_rec)
	  max_p_rec = p_x_to_k;
      }
      
      ret = p(obs(t-1), k) * max_p_rec;
    }
    
    if(single.memoizing)
      single.memoized[t][k] = ret;
    return ret;
  }
}


