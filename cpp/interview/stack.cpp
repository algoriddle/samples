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

    auto tmp = std::move(head_); // unique_ptr should automatically delete previous head_
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

  T& operator[](unsigned int n)
  {
    Item *item = head_.get();
    while (item) {
      if (n == 0)
        return item->value_;
      --n;
      item = item->next_.get();
    }
    throw std::out_of_range("Stack::operator[]");
  }

  T& NthToLast(int n)
  {
    Item *p1, *p2;
    p1 = p2 = head_.get();
    while (p2) {
      if (n == 0)
        break;
      n--;
      p2 = p2->next_.get();
    }

    if (!p2)
      throw std::out_of_range("Stack::NthToLast");

    while (p2->next_) {
      p1 = p1->next_.get();
      p2 = p2->next_.get();
    }
    return p1->value_;
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
    Item(T &value, std::unique_ptr<Item> &next) : value_(std::move(value)), next_(std::move(next)) {}
    Item(const T &value, std::unique_ptr<Item> &next) : value_(value), next_(std::move(next)) {}

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
  Stack<Test> xs{ 5, 10, 20 };
  xs.Push(12);
  assert(xs.Peek() == 12);
  xs.Push(23);
  assert(xs.Peek() == 23);
  xs.Push(35);
  assert(xs.Peek() == 35);
  Test x = xs.Pop();
  assert(xs.Peek() == 23);
  std::cout << xs << "\n";
  xs.Reverse();
  std::cout << xs << "\n" << x << "\n" << xs[0] << " " << xs[3] << " " << xs.NthToLast(0) << " " << xs.NthToLast(3) << "\n";
  Test y = xs.Pop();
  x = y;
  y = std::move(x);

  Stack<std::unique_ptr<Test>> alma;
  alma.Push(std::make_unique<Test>(12));
  assert(*alma.Peek() == 12);

  std::vector<std::unique_ptr<Test>> korte(0);
  korte.push_back(std::make_unique<Test>(3));
}
