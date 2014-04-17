#ifdef _WIN32
#define _CRTDBG_MAP_ALLOC
#endif

#include <stdlib.h>

#ifdef _WIN32
#include <crtdbg.h>
#endif

#include <list>
#include <iostream>

using std::cout;
using std::list;

void quicksort(list<int> &xs, const list<int>::iterator &from, const list<int>::iterator &to)
{
  if (from == to)
    return;
  int x = *from;
  auto start = from;
  for (auto it = from; it != xs.end(); ++it) {
    if (*it < x) {
      xs.splice(from, xs, it);
      if (start == from)
        --start;
    }
  }
  quicksort(xs, start, from);
  start = from;
  start++;
  quicksort(xs, start, to);
}

int main()
{
#ifdef _WIN32
  _CrtSetDbgFlag(_CRTDBG_ALLOC_MEM_DF | _CRTDBG_LEAK_CHECK_DF);
#endif

  list<int> input{ 8, 5, 7, 4, 6, 2, 3, 10, 1, 9 };
  quicksort(input, input.begin(), input.end());
  for (auto &i : input)
    cout << i << " ";
}
