import java.util.Arrays;

int t = 0;
int max_n, max_t;

void setup(){
  size(700, 700);
  background(255);
  visit_count = new int[1001];
  //draw_func_seive();
  //draw_seive();
  draw_inc_seive();

  //  save("out.png");
}

int[] visit_count;

int[] verify_primes = {
  2, 3, 5, 7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71 ,73,79,83,
  89,97,101,103,107,109,113,127,131,137,139,149,151,157,163,167,173,179,
  181,191,193,197,199,211,223,227,229,233,239,241,251,257,263,269,271,
  277,281,283,293,307,311,313,317,331,337,347,349,353,359,367,373,379,
  383,389,397,401,409,419,421,431,433,439,443,449,457,461,463,467,479,
  487,491,499,503,509,521,523,541,547,557,563,569,571,577,587,593,599,
  601,607,613,617,619,631,641,643,647,653,659,661,673,677,683,691,701,
  709,719,727,733,739,743,751,757,761,769,773,787,797,809,811,821,823,
  827,829,839,853,857,859,863,877,881,883,887,907,911,919,929,937,941,
  947,953,967,971,977,983,991,997};

void check_primes(int val, int n){
  assert verify_primes[n] == val;
}

void draw_inc_seive(){
  max_n = 1000; // 100 -> 146; 1000 -> 1958 // for func1, t= 15620
  max_t = 1958;
  incremental_seive(max_n);
}
void draw_seive(){
  max_n = 1000; // 100 -> 146; 1000 -> 1958 // for func1, t= 15620
  max_t = 1958;
  classic_seive(max_n);
}
void draw_func_seive(){
  max_n = 1000;
  max_t = 15620;
  func_seive(max_n);
}
void classic_seive(int n){
  // Classic seive
  boolean[] l = new boolean[n + 1];
  int p = 2;
  while(p <= n){
    for(int marker = 2 * p; marker <= n; marker += p){
      assert(marker % p == 0);
      l[marker] = true;
      visit(marker);
    }
    for(p++; p <= n && l[p]; p++){
      // increment p until l[p] is false.
    }
  }
  
  int count = 0;  
  for(int i  = 2; i <= n; i++){
    if (!l[i]){
      check_primes(i, count++);
    }
  }
  println(t);
}

void func_seive(int n){
  // list from 2 to n
  ArrayList<Integer> vals = new ArrayList<Integer>();
  for (int t = 2; t <= n; t++){
    vals.add(t);
  }
  vals = func_seive_helper(vals);
  int count = 0;
  for(Integer i : vals){
    check_primes(i, count++);
  }
  println(t);
}

ArrayList<Integer> func_seive_helper(ArrayList<Integer> vals){
  // Classic functional "seive"
  // returns v[0] + lazy_seive_1([i for i in vals where i % v[0] == 0])
  if(vals.size() == 0)
    return vals;
  int cur = vals.get(0);
  ArrayList<Integer> filtered = new ArrayList<Integer>();
  for(Integer i : vals){
    if(i == cur){
      continue;
    }else{
      visit(i);
      if(i % cur != 0){
        filtered.add(i);
      }
    }
  }
  filtered = func_seive_helper(filtered);
  filtered.add(0, cur);
  return filtered;
}

void fix_table(int prev_max, int cur_max, int[] l){
  int p = 2;
  while (p <= cur_max){
    if(l[p] == 0){
      l[p] = p;
    }
    for(int marker = p + l[p]; marker <= cur_max; marker += p){
      assert(marker % p == 0);
      l[marker] = 1;
      visit(marker);
      l[p] = marker;
    }
    for(p++; p <= cur_max && l[p] == 1; p++){
      // increment p until l[p] is false.
    }
  }
}

void incremental_seive(int n){
  int[] l = new int[n + 1];
  int table_size = 100;
  int p = 2;
  fix_table(table_size, table_size, l);
  while(table_size < n){
    int prev_size = table_size;
    table_size *= 2;
    if(table_size > n){
      table_size = n;
    }
    l = Arrays.copyOf(l, table_size + 1);
    fix_table(prev_size, table_size, l);
  }

  int count = 0;  
  for(int i  = 2; i <= n; i++){
    if (l[i] != 1){
      check_primes(i, count++);
    }
  }
  
  println(t);
}

void visit(int n){
  // visit the number n.
  t++;

  fill(10 * visit_count[n], 102, 204);

  ellipse(map(n, 0, max_n, 0, width),
          map(t, 0, max_t, height, 0), 7, 7);
  visit_count[n]++;

}

