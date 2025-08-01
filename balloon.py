from __future__ import annotations

from dataclasses import dataclass
from types import NoneType
from typing import Optional
from icecream.icecream import print_function
from result import Result, Ok, Err
from icecream import ic
import os
import sys

from typing import TYPE_CHECKING
if TYPE_CHECKING:
    from _typeshed import StrPath

WORK_DIR: StrPath = os.getcwd() + '/'

@dataclass
class Tag:
    value: str
    trail: Optional[str]

    def __post_init__(self) -> None:
        self.trail = self.trail if (self.trail is not None) and (self.trail.strip() != '') else None

    # Returns the type of tag.
    def type(self) -> str:
        type = str()

        for c in self.value:
            if c.isspace():
                break

            type += c

        return type

    def get_param(self, param: str) -> Optional[str]:
        pos = self.value.find(param) + param.__len__() + len('="')

        if pos == -1:
            return None

        param_value = str()

        for idx in range(pos, (self.value.__len__() - param.__len__())):
            param_value += self.value[idx]

        return param_value

    def write(self) -> str:
        return f'<{self.value}>{self.trail if self.trail != None else ''}'

@dataclass
class HTML:
    value: str

    # Returns all tags in order in the html file.
    def tags(self) -> list[Tag]:
        tag = str()
        trail: Optional[str] = str()
        tags = list()
        record = False

        for c in self.value:
            if c == '<' and tag != '':
                tags.append(Tag(tag, trail))
                tag = str()
                trail = str()

            if c == '<' or c == '>':
                record = not record # why can't I have ! operator...
            elif record == True:
                tag += c
            else:
                trail += c

        tags.append(Tag(tag, trail))
        return tags

    def inflate(self) -> Result[str, str]:
        file = str()

        for tag in self.tags():
            if tag.type() == 'include':
                chunk = tag.get_param('src')
                if isinstance(chunk, NoneType):
                    return Err('FileNotFoundError')

                html = HTML(open(str(WORK_DIR) + '/src/' + chunk, 'rt').read())
                file += html.inflate().expect('FileNotFoundError')
            else:
                file += tag.write()

        return Ok(file)

    # Convert the HTML obj into a str to write to file.
    def write(self) -> str:
        return self.inflate().unwrap()


def main() -> None:
    # If:
    #   Incorrect number of arguments
    #   Long help flag
    #   Short help flag
    if len(sys.argv) != 3 or (
        sys.argv[0] == '--help'
        or sys.argv[0] == '-h'
    ):
        help()
        return

    with open(str(WORK_DIR) + sys.argv[1], 'rt') as f:
        html_src = HTML(f.read())

    # Patch to make sure that target paths are available.
    try:
        os.makedirs(str(WORK_DIR) + os.path.dirname(sys.argv[2]))
    except FileExistsError:
        pass

    with open(str(WORK_DIR) + sys.argv[2], 'w') as f:
        f.write(html_src.write())

def help() -> None:
    print('Usage: python balloon.py [OPTIONS] <SOURCE> <DESTINATION>')
    print()
    print()
    print('Options:')
    print('-h, --help       Print help')

if __name__ == '__main__':
    main()
