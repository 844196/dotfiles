import { type BranchSummaryBranch, emoji, match, P, z } from "../deps.ts";

const divergedSchema = z
  .object({
    ahead: z.number().nonnegative(),
    behind: z.number().nonnegative(),
  })
  .or(z.literal("GONE"));
export type Diverged = Readonly<z.infer<typeof divergedSchema>>;

export const branchSchema = z.object({
  name: z.string().min(1),
  headSubject: z.string().min(1)
    .transform((x) => emoji.emojify(x)),
  diverged: divergedSchema,
  isCurrent: z.boolean(),
});
export type Branch = Readonly<z.infer<typeof branchSchema>>;

export const isGone = (x: Branch) => x.diverged === "GONE";

export const isTopicBranch = (x: Branch) => x.name.includes("/");

// for SimpleGit
export function fromSimpleGitBranch(input: BranchSummaryBranch): Branch {
  const [_, ahead, behind, gone, headSubject] = input.label.match(
    /^(?:\[(?:(?:ahead (?<ahead>\d+))?(?:, )?(?:behind (?<behind>\d+))?|(?<gone>gone))\])? ?(?<headSubject>.*)$/,
  ) ??
    [] as unknown as [
      unknown,
      string | undefined,
      string | undefined,
      string | undefined,
      string,
    ];

  return branchSchema.parse(
    {
      name: input.name,
      headSubject,
      isCurrent: input.current,
      diverged: match([ahead ?? "0", behind ?? "0", gone])
        .with([P._, P._, "gone"], () => "GONE" as const)
        .otherwise(([a, b]) => ({ ahead: Number(a), behind: Number(b) })),
    } satisfies Branch,
  );
}
