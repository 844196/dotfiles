import { assertEquals } from "../dev_deps.ts";
import { compareBool, concatComparator } from "./comparison.ts";

Deno.test("compareBool", () => {
  const matrix: [boolean, boolean, number][] = [
    [true, true, 0],
    [false, false, 0],
    [true, false, 1],
    [false, true, -1],
  ];

  for (const [left, right, expected] of matrix) {
    assertEquals(compareBool(left, right), expected);
  }
});

Deno.test("concatComparator", () => {
  type User = {
    age: number;
    name: string;
  };

  const users: User[] = [
    { name: "def", age: 60 },
    { name: "abc", age: 24 },
    { name: "ghi", age: 10 },
    { name: "jkl", age: 24 },
  ];

  const compareName = (a: User, b: User) => a.name.localeCompare(b.name);
  const compareAge = (a: User, b: User) => a.age - b.age;

  const actual = users.toSorted(concatComparator(compareAge, compareName));
  const expected: User[] = [
    { name: "ghi", age: 10 },
    { name: "abc", age: 24 },
    { name: "jkl", age: 24 },
    { name: "def", age: 60 },
  ];

  assertEquals(actual, expected);
});
