#include <iostream>
#include <memory>
#include <stdexcept>
#include <array>
#include <stdexcept>
#include <cstdio>
#include <string>
#include <vector>
#include <future>
#include <chrono>
#include <experimental/filesystem>
#include <thread>
#include <mutex>
#include <condition_variable>
#include <sstream>

using namespace std;

/*
 *run system with compiler, flags, and path and remains 
*/
int f(string compiler, string output, string flags, string path, string remains) 
{
  string cmd = compiler + output + flags + path + remains;
  int tmp = system(cmd.c_str());
  return 0;
}


/*
 *f() but with return code of the system
*/
int f_test(string compiler, string flags, string path, string remains) 
{
  string cmd = compiler + flags + path + remains;
  //cerr << cmd << '\n';
  return system(cmd.c_str());
}


/*
 *wrapper to force time-out: source: https://stackoverflow.com/questions/40550730/how-to-implement-timeout-for-function-in-c
 *TODO: source is stack overflow, is there a more efficient way to do it with async?
*/
int f_wrapper(string compiler, string output, string flags, string path, string remains)
{
  std::mutex m;
  std::condition_variable cv;
  int retValue;

  std::thread t([&m, &cv, &retValue, &compiler, &output, &flags, &path, &remains]() 
      {
      retValue = f(compiler, output, flags, path, remains);
      cv.notify_one();
      });

  t.detach();

  {
    std::unique_lock<std::mutex> l(m);
    if(cv.wait_for(l, 2s) == std::cv_status::timeout) 
      throw std::runtime_error("Timeout");
  }

  return retValue;    
}


/*
 *f() but checks if compild by checking for binary
*/
int f_test2(string compiler, string flags, string path) {
  string cmd = compiler + flags + path + ") 2> /dev/null";
  cerr << cmd << '\n';
  array<char, 128> buffer;
  string res;
  shared_ptr<FILE> pipe(popen(cmd.c_str(), "r"), pclose);
  if (!pipe) {
    throw runtime_error("popen() failed!");
  }
  while (!feof(pipe.get())) {
    if (fgets(buffer.data(), 128, pipe.get()) != nullptr) {
      res += buffer.data();
    }
  }
  //cout << res << '\n';
  return res.find("Binary");
}


/*
 *join_contracts selects N contracts which can compile together correctly
*/
int join_contracts(string compiler, string select_flag,
	string path, string &test_string, vector<string> &sol_files, int N) 
{

  for (auto &p : std::experimental::filesystem::directory_iterator(path)) {
    cout << sol_files.size() << '\n';
    if(sol_files.size() == N)
      return N;

    string test_string_tmp = "";
    string temp = string(p.path().c_str());
    //cout << "temp = :  " << temp << '\n';
    if (temp.find(".sol") != -1 && temp.find(" ") == -1) {
      test_string_tmp = test_string + temp + " ";
      cout << "test string: " << test_string_tmp << '\n';
      if(f_test2(compiler, select_flag, test_string_tmp) != -1) {
	sol_files.push_back(temp);
	test_string = test_string_tmp;
      } else {
	cerr << "caught exception" << '\n';
	continue;
      }
    }

  }
  return sol_files.size();
}


/*
 *time testing single thread vs multi-thread using async
 */
void time_test(const vector<string> &sol_files, string test_string, 
	string compiler, string flags, string remains, string output_single, string output_multi)
{
  //obtain num cpus
  int cpus = std::thread::hardware_concurrency();
  if (cpus <= 1) { cpus = 1; }
  cout << "Number of cpus: " << cpus << "\n"; 
  
  int count = 0;
  int rems = sol_files.size() % cpus;
  vector<future<int>> vec_res;
 
  //single thread execution
  auto t1 = std::chrono::high_resolution_clock::now();
  f(compiler, output_single, flags, test_string, remains);
  auto t2 = std::chrono::high_resolution_clock::now();
  
  //multi thread instantiation
  auto t3 = std::chrono::high_resolution_clock::now();
  if (cpus <= 1 || sol_files.size() == 1) {
    f(compiler, output_multi, flags, test_string, remains);
  } else {
    int task_for_each_cpu;
    if (sol_files.size() < cpus) { 
      cpus = sol_files.size();
      task_for_each_cpu = 1;
      rems = 0;
    } else {
      task_for_each_cpu = sol_files.size() / cpus;
    }

    //asign efficiently tasks to each cpu
    vector<string> tasks;
    for (int i = 0; i < cpus; i++) {
      string temp = string("");
      for (int j = 0; j < task_for_each_cpu; j++) {
	temp = temp + sol_files[count] + " ";
	count++;
      }
      if (rems > 0) {
	rems--;
	temp = temp + sol_files[count] + " ";
	count++;
      }
      tasks.push_back(temp);
    }
    t3 = std::chrono::high_resolution_clock::now();
    //TODO: is this the most efficient way, i.e. cycle through all asyncs and get
    for (auto task : tasks) {
      vec_res.push_back(async(std::launch::async, f, compiler, output_multi, flags, task, remains));
    }
    for (int k = 0; k < vec_res.size(); k++) {
      vec_res[k].get();
    }
  }
  auto t4 = std::chrono::high_resolution_clock::now();
  cout << "Done.\n Time used without async: " << std::chrono::duration_cast<std::chrono::microseconds>(t2 - t1).count() << " microseconds.\n";
  cout << "Time used with async: " << std::chrono::duration_cast<std::chrono::microseconds>(t4 - t3).count() << " microseconds.\n";	

}


int main(int argc, char** argv) 
{
  if(argc < 3){
    cerr << "[test] [N] [path]" << '\n';
    cerr << "N is number of independent files wanting to compile" << '\n';
    cerr << "path is the path of where to find these. E.g. cloning github-soliditiy-all/contracts/ into this directory" << '\n';
    return 0;
  }

  string compiler = "(../build/solc/solc ";
  string flags1 ="--optimize --ignore-missing --bin ";
  string flags ="--optimize --ignore-missing --combined-json abi,asm,ast,bin,bin-runtime,clone-bin,compact-format,devdoc,hashes,interface,metadata,opcodes,srcmap,srcmap-runtime,userdoc ";
  string select_flag = "--bin ";
  //string files1 = "*.sol ";
  //string files2 = "*/*.sol";
  string output_single = "-o single_thread/ ";
  string output_multi = "-o multi_thread/ ";

  string remains = ") >/dev/null 2>&1";

  //string path = "./github-solidity-all/contracts/";
  //string path = "/tmp/tmp.rRjDzGuVRp";
  
  istringstream ss(argv[1]);
  int N;
  if (!(ss >> N)){
    cerr << "Invalid argument for N: " << argv[1] << '\n';
    return 0;
  }
  
  if (N <= 0) {
    cerr << "Please enter positive number for N" << '\n';
    return 0;
  }  

  istringstream ss1(argv[2]);
  string path;
  if (!(ss1 >> path)){
    cerr << "Invalid argument for path: " << argv[2] << '\n';
    return 0;
  }  

  
  string test_string = "";
  vector <string> sol_files;
  
  if(join_contracts(compiler, select_flag, path, test_string, sol_files, N) != N){
    cerr << "Not enough files in directory to satisfy N" << '\n';
    return 0;
  }
  
  cout << test_string << '\n';
  time_test(sol_files, test_string, compiler, flags1, remains, output_single, output_multi);
  return 0; 
}
