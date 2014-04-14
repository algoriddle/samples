#ifdef _WIN32
#define _CRTDBG_MAP_ALLOC
#endif

#include <stdlib.h>

#ifdef _WIN32
#include <crtdbg.h>
#endif

#include <iostream>
#include <memory>
#include <cassert>
#include <vector>

template <typename T>
class Stack
{
 public:
  Stack() {};

  Stack(std::initializer_list<T> values)
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
    head_ = std::make_unique<Item>(value, head_);
  }

  void Push(const T &value)
  {
    head_ = std::make_unique<Item>(value, head_);
  }

  T Pop()
  {
    if (!head_)
      throw std::out_of_range("Stack::Pop");

    auto tmp = std::move(head_); // unique_ptr deletes previous head_
    head_ = std::move(tmp->next_);
    //		return tmp->value;
    return std::move(tmp->value_);
  };

  const T& Peek() const
  {
    return head_->value_;
  }

  void Reverse()
  {
    std::unique_ptr<Item> last;
    std::unique_ptr<Item> current = std::move(head_);

    while (current) {
      std::unique_ptr<Item> next = std::move(current->next_);
      current->next_ = std::move(last);
      last = std::move(current);
      current = std::move(next);
    }

    head_ = std::move(last);
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
      throw std::out_of_range("Stack::operator[+]");
    } else { // n < 0
      Item *item = head_.get(), *lookahead = item;
      while (lookahead) {
        if (n == -1)
          break;
        ++n;
        lookahead = lookahead->next_.get();
      }
      if (!lookahead)
        throw std::out_of_range("Stack::operator[-]");
      while (lookahead->next_) { // does lookahead point to last?
        item = item->next_.get();
        lookahead = lookahead->next_.get();
      }
      return item->value_;
    }
  }

  friend std::ostream& operator<<(std::ostream& stream, const Stack& list)
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
    Item(T &value, std::unique_ptr<Item> &next) 
      :value_(std::move(value)), next_(std::move(next)) {}
    Item(const T &value, std::unique_ptr<Item> &next) 
      :value_(value), next_(std::move(next)) {}

    T value_;
    std::unique_ptr<Item> next_;
  };

  std::unique_ptr<Item> head_;
};

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

  friend std::ostream& operator<<(std::ostream& stream, const Test& test)
  {
    stream << test.x;
    return stream;
  }

private:
  int x;
};

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
  std::cout << xs << "\n"; // 6 5 4 3 2 1
  xs.Reverse();
  std::cout << xs << "\n"; // 1 2 3 4 5 6

  std::cout << "[0] -> " << xs[0] 
    << "\n[3] -> " << xs[3] 
    << "\n[-1] -> " << xs[-1] 
    << "\n[-4] -> " << xs[-4] << "\n";

  Test y = xs.Pop();
  Test x = y;
  y = std::move(x);

  Stack<std::unique_ptr<Test>> s;
  s.Push(std::make_unique<Test>(12));
  assert(*s.Peek() == 12);

  std::vector<std::unique_ptr<Test>> v(0);
  v.push_back(std::make_unique<Test>(3));
}
