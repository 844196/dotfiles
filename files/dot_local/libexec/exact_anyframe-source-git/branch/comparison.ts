export const compareBool = (a: boolean, b: boolean) => Number(a) - Number(b);

export const concatComparator =
  <T>(...comparators: ((a: T, b: T) => number)[]) => (a: T, b: T) => {
    for (const comparator of comparators) {
      const ord = comparator(a, b);
      if (ord !== 0) {
        return ord;
      }
    }
    return 0;
  };
