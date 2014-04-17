#ifdef _WIN32
#define _CRTDBG_MAP_ALLOC
#endif

#include <stdlib.h>

#ifdef _WIN32
#include <crtdbg.h>
#endif

#include <cassert>
#include <iostream>
#include <memory>
#include <unordered_set>
#include <vector>

using std::initializer_list;
using std::cout;
using std::make_unique;
using std::move;
using std::ostream;
using std::out_of_range;
using std::unordered_set;
using std::unique_ptr;
using std::vector;

template <typename T>
class Stack
{
 public:
  Stack() {};

  Stack(initializer_list<T> values)
  {
    for (const T& value : values)
      Push(value);
  }

  Stack(const Stack &src) = delete;
  Stack& operator=(const Stack &src) = delete;
  Stack(Stack &&src) = delete;
  Stack& operator=(Stack &&src) = delete;

  ~Stack() {};

  void Push(T &&value)
  {
    head_ = make_unique<Item>(value, head_);
  }

  void Push(const T &value)
  {
    head_ = make_unique<Item>(value, head_);
  }

  T Pop()
  {
    if (!head_)
      throw out_of_range("Stack::Pop");

    auto tmp = move(head_); // unique_ptr deletes previous head_
    head_ = move(tmp->next_);
    //		return tmp->value;
    return move(tmp->value_);
  };

  const T& Peek() const
  {
    return head_->value_;
  }

  void Reverse()
  {
    unique_ptr<Item> last;
    unique_ptr<Item> current = move(head_);

    while (current) {
      unique_ptr<Item> next = move(current->next_);
      current->next_ = move(last);
      last = move(current);
      current = move(next);
    }

    head_ = move(last);
  }
  
  void RemoveDuplicates_1()
  {
    unordered_set<T> dupe_check;
    Item *previous = nullptr, *item = head_.get();
    while (item) {
      if (dupe_check.find(item->value_) == dupe_check.end()) {
        dupe_check.insert(item->value_);
        previous = item;
      }
      else {
        previous->next_ = move(item->next_);
      }
      item = previous->next_.get();
    }
  }
  
  void RemoveDuplicates_2()
  {
    unordered_set<T> dupe_check;
    Item *item = head_.get();
    if (!item)
      return;
    dupe_check.insert(item->value_);
    while (item->next_) {
      if (dupe_check.find(item->next_->value_) == dupe_check.end()) {
        dupe_check.insert(item->next_->value_);
        item = item->next_.get();
      }
      else {
        item->next_ = move(item->next_->next_);
      }
    }
  }

  void RemoveDuplicates_3()
  {
    Item *item = head_.get();
    while (item) {
      Item *runner = item;
      while (runner->next_) {
        if (runner->next_->value_ == item->value_)
          runner->next_ = move(runner->next_->next_);
        else
          runner = runner->next_.get();
      }
      item = item->next_.get();
    }
  }

  T& operator[](int n)
  {
    if (n >= 0) {
      Item *item = head_.get();
      while (item) {
        if (n == 0)
          return item->value_;
        --n;
        item = item->next_.get();
      }
      throw out_of_range("Stack::operator[+]");
    } else { // n < 0
      Item *item = head_.get(), *lookahead = item;
      while (lookahead) {
        if (n == -1)
          break;
        ++n;
        lookahead = lookahead->next_.get();
      }
      if (!lookahead)
        throw out_of_range("Stack::operator[-]");
      while (lookahead->next_) { // does lookahead point to last?
        item = item->next_.get();
        lookahead = lookahead->next_.get();
      }
      return item->value_;
    }
  }

  friend ostream& operator<<(ostream& stream, const Stack& list)
  {
    Item *item = list.head_.get();
    while (item) {
      stream << item->value_;
      stream << " ";
      item = item->next_.get();
    }
    return stream;
  }

 private:
  struct Item
  {
    Item(T &value, unique_ptr<Item> &next) 
      :value_(move(value)), next_(move(next)) {}
    Item(const T &value, unique_ptr<Item> &next) 
      :value_(value), next_(move(next)) {}

    T value_;
    unique_ptr<Item> next_;
  };

  unique_ptr<Item> head_;
};

class Test;

namespace std {
  template<>
  class hash<Test> {
  public:
    size_t operator()(const Test &test) const;
  };
}

class Test
{
public:
  Test(int _x) : x(_x) {};

  Test(const Test &src)
  {
    x = src.x;
  }

  Test &operator=(const Test &src)
  {
    x = src.x;
    return *this;
  }

  Test(Test &&src)
  {
    x = src.x;
    src.x = 0;
  }

  Test &operator=(Test &&src)
  {
    x = src.x;
    src.x = 0;
    return *this;
  }

  bool operator==(const Test &other) const
  {
    return (x == other.x);
  }

  friend ostream& operator<<(ostream& stream, const Test& test)
  {
    stream << test.x;
    return stream;
  }

  friend class std::hash<Test>;

private:
  int x;
};

namespace std {
  size_t hash<Test>::operator()(const Test &test) const
  {
      return hash<int>()(test.x);
  }
}

int main()
{
#ifdef _WIN32
  _CrtSetDbgFlag(_CRTDBG_ALLOC_MEM_DF | _CRTDBG_LEAK_CHECK_DF);
#endif
  Stack<Test> xs{ 1, 2, 3, 4, 5 };
  xs.Push(6);
  assert(xs.Peek() == 6);
  xs.Push(7);
  assert(xs.Peek() == 7);
  assert(xs.Pop() == 7);
  assert(xs.Peek() == 6);
  cout << xs << "\n"; // 6 5 4 3 2 1
  xs.Reverse();
  cout << xs << "\n"; // 1 2 3 4 5 6

  cout << "[0] -> " << xs[0] 
    << "\n[3] -> " << xs[3] 
    << "\n[-1] -> " << xs[-1] 
    << "\n[-4] -> " << xs[-4] << "\n";

  xs.Push(1);
  xs.Push(6);
  cout << xs << "\n"; // 6 1 1 2 3 4 5 6
  xs.RemoveDuplicates_1();
  cout << xs << "\n"; // 6 1 2 3 4 5

  xs.Push(1);
  xs.Push(5);
  cout << xs << "\n"; // 5 1 6 1 2 3 4 5
  xs.RemoveDuplicates_2();
  cout << xs << "\n"; // 5 1 6 2 3 4

  xs.Push(1);
  xs.Push(4);
  cout << xs << "\n"; // 4 1 5 1 6 2 3 4
  xs.RemoveDuplicates_3();
  cout << xs << "\n"; // 4 1 5 6 2 3

  Test y = xs.Pop();
  Test x = y;
  y = move(x);
  
  Stack<unique_ptr<Test>> s;
  s.Push(make_unique<Test>(12));
  assert(*s.Peek() == 12);

  vector<unique_ptr<Test>> v(0);
  v.push_back(make_unique<Test>(3));
}
