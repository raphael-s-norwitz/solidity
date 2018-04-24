#include <iostream>
#include <memory>
#include <stdexcept>
#include <array>
#include <stdexcept>
#include <cstdio>
#include <string>
#include <vector>
#include <future>
#include <algorithm>
#include <experimental/filesystem>

using namespace std;
std::experimental::filesystem::path root_path;
/*
   run system with compiler, flags, and path
*/
int compile(string compiler, string flags, string files, std::experimental::filesystem::path current) 
{
  string cur = current.string();
  std::experimental::filesystem::path output_dir = cur + (cur[cur.length() - 1] == '/' ? "bin" : "/bin");
  std::experimental::filesystem::create_directory(output_dir);
  string cmd = compiler + " -o " + current.string() + "/bin/ " + flags + " " + files;
  return system(cmd.c_str());
}

/*
    start a parallel compiling process
*/
void parallel_compile(string& compiler, string& flags, vector<string> &sources, vector<future<int>> &vec_res) {
  //obtain num cpus
  int cpus = std::thread::hardware_concurrency();
  if (cpus <= 1) { cpus = 1; }
  cout << "Number of cpus: " << cpus << "\n"; 
  
  int count = 0;
  int rems = sources.size() % cpus;
 
  if (cpus <= 1 || sources.size() == 1) {
    string to_compile;
    for (auto & str : sources) {
      to_compile += str + " ";
    }
    compile(compiler, flags, to_compile, root_path);
  } else {
    int task_for_each_cpu;
    if (sources.size() < cpus) { 
      cpus = sources.size();
      task_for_each_cpu = 1;
      rems = 0;
    } else {
      task_for_each_cpu = sources.size() / cpus;
    }

    // asign efficiently tasks to each cpu
    vector<string> tasks;
    for (int i = 0; i < cpus; i++) {
      string temp;
      for (int j = 0 && count < sources.size(); j < task_for_each_cpu; j++) {
        temp = temp + sources[count] + " ";
        count++;
      }
      if (rems > 0) {
        rems--;
        temp = temp + sources[count] + " ";
        count++;
      }
      tasks.push_back(temp);
    }
    //TODO: is this the most efficient way, i.e. cycle through all asyncs and get
    for (auto task : tasks) {
      vec_res.push_back(async(std::launch::async, compile, compiler, flags, task, root_path));
    }
  }
}

void distribute_tasks(string& path, string& extension, vector<tuple<std::experimental::filesystem::path, vector<string>>>& pool, bool isRoot) {
  vector<string> sources;
  if (isRoot) {
    for (auto &p : std::experimental::filesystem::directory_iterator(path)) {
      if (!std::experimental::filesystem::is_directory(p)) {
        string temp = p.path().string();
        if (temp.find(extension) != -1 && temp.find(extension) == temp.length() - extension.length())
          sources.push_back(temp);
      } else {
        string temp = p.path().string();
        distribute_tasks(temp, extension, pool, false);
      }
    }
  } else {
    sources.push_back(path + ("/*") + extension);
    sources.push_back(path + ("/*/*") + extension);
  }
  if (sources.size() != 0) {
    std::experimental::filesystem::path p = path;
    pool.push_back(make_tuple(p, sources));
  }
}

int main(int argc, char** argv) 
{
  if (argc < 5) {

    cerr << "[executable] [path_to_compiler] [flags] [directory] [extension]" << '\n';
    cerr << "[path_to_compiler] is the path to the compiler executable.\n";
    cerr << "[flags] is the flags for the compiler executable, like \"--bin\" for solidity.\n";
    cerr << "[directory] is the top level directory of the code to compile." << '\n';
    cerr << "[extension] is the extension for the files to compile. For example: .sol" << '\n';

    return 0;
  }

  string compiler = string(argv[1]);
  string flags = string(argv[2]);
  string path;
  string extension = string(argv[4]);
  vector<tuple<std::experimental::filesystem::path, vector<string>>> pool;
  vector<future<int>> vec_res;
  root_path = std::experimental::filesystem::system_complete(argv[3]);
  path = root_path.string();
  distribute_tasks(path, extension, pool, true);

  for (auto & p : pool) {
    auto[path, sources] = p;
    if (path == root_path) {
      parallel_compile(compiler, flags, sources, vec_res);
    } else {
      string tasks;
      for (auto & task : sources) {
        tasks += task + " ";
      }
      vec_res.push_back(async(std::launch::async, compile, compiler, flags, tasks, path));
    }
  }
  for_each(vec_res.begin(), vec_res.end(), [](future<int> &res){ res.get(); });
  
  return 0; 
}
