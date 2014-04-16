#ifdef _WIN32
#define _CRTDBG_MAP_ALLOC
#endif

#include <stdlib.h>

#ifdef _WIN32
#include <crtdbg.h>
#endif

#include <iostream>
#include <string>
#include <cassert>

using std::string;
using std::cout;
using std::to_string;

// ASCII only (< 128)
bool all_unique_1(char *s)
{
  if (strlen(s) > CHAR_MAX) // 127
    return false;

  bool dupes[CHAR_MAX] { false };
  while (*s) {
    if (dupes[*s])
      return false;
    dupes[*s] = true;
    ++s;
  }
  return true;
}

// a-z only
bool all_unique_2(char *s)
{
  if (strlen(s) > 26) // a-z
    return false;

  int dupes = 0;
  while (*s) {
    int x = *s - 'a';
    if ((dupes & (1 << x)) != 0)
      return false;
    dupes |= (1 << x);
    ++s;
  }
  return true;
}

void reverse(char *s)
{
  char *end = s;
  while (*end) {
    ++end;
  }
  --end;
  while (s < end) {
    char tmp = *end;
    *end = *s;
    *s = tmp;
    ++s;
    --end;
  }
}

// ASCII
bool is_permutation(char *s1, char *s2)
{
  if (strlen(s1) != strlen(s2))
    return false;

  int counter[CHAR_MAX] { 0 };
  while (*s1) {
    ++counter[*s1];
    ++s1;
  }

  while (*s2) {
    --counter[*s2];
    if (counter[*s2] < 0)
      return false;
    ++s2;
  }

  return true;
}

void escape_spaces(char *s, int length)
{
  int spaces = 0;
  for (int i = 0; i < length; i++)
    if (s[i] == ' ')
      ++spaces;
  
  char *w = s + length + spaces * 2;
  char *r = s + length;

  while (w >= s) {
    if (*r == ' ') {
      *w-- = '0';
      *w-- = '2';
      *w-- = '%';
    }
    else {
      *w-- = *r;
    }
    --r;
  }
}

string compress(const string& s)
{
  string compressed;

  char last_character = 0;
  int char_count = 1;
  for (const char &c : s) {
    if (c == last_character) {
      ++char_count;
    }
    else {
      if (last_character != 0) {
        compressed += last_character;
        compressed.append(to_string(char_count));
      }
      last_character = c;
      char_count = 1;
    }
  }
  if (last_character != 0) {
    compressed += last_character;
    compressed.append(to_string(char_count));
  }
  if (compressed.length() < s.length())
    return compressed;
  else
    return s;
}

bool is_rotation(const string& s1, const string& s2)
{
  return (s1.length() == s2.length() && (s1 + s1).find(s2) != string::npos);
}

int main()
{
#ifdef _WIN32
  _CrtSetDbgFlag(_CRTDBG_ALLOC_MEM_DF | _CRTDBG_LEAK_CHECK_DF);
#endif
  char *s = new char[14];
  strcpy(s, "t e s t");
  reverse(s);
  cout << s << "\n"; // "t s e t"
  cout << all_unique_1(s) << "\n"; // false
  cout << all_unique_2(s) << "\n"; // false
  cout << is_permutation("test", "goal") << "\n"; // false
  cout << is_permutation("test", "ttse") << "\n"; // true
  escape_spaces(s, 7);
  cout << s << "\n"; // "t%20s%20e%20t"
  cout << compress("abcdddddddef") << "\n"; // "abcdddddddef"
  cout << compress("abcddddddddef") << "\n"; // "a1b1c1d8e1f1"
  cout << is_rotation("erbottlewat", "waterbottle") << "\n"; // true
  cout << is_rotation("erbottlewat", "waerbottle") << "\n"; // false
}
