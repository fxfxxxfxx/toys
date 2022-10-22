from string import ascii_lowercase
from string import ascii_uppercase
from argparse import ArgumentParser

M = {
    "0": ":zero:",        
    "1": ":one:",
    "2": ":two:", 
    "3": ":three:",
    "4": ":four:",
    "5": ":five:",
    "6": ":six:",
    "7": ":seven:",
    "8": ":eight:",
    "9": ":nine:",
}
M.update({
    c: f":regional_indicator_{c}:" for c in ascii_lowercase
})
M.update({
    c: f":regional_indicator_{c.lower()}:" for c in ascii_uppercase
})


def f(n: str) -> str:
    return " ".join(map(lambda x: M.get(x) if M.get(x) else x, n))

desc = """
Change alphanumeric characters to emojis in discord.
"""

if __name__ == '__main__':
    parser = ArgumentParser(description=desc)
    parser.add_argument('content', type=str)
    args = parser.parse_args()
    print(f(args.content))
