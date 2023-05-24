import re
from PySide6.QtQml import QmlElement
from PySide6.QtCore import Slot, QObject, Property, Signal
from PyPDF2 import PdfReader, PdfWriter
from PyPDF2.generic import Destination, IndirectObject

QML_IMPORT_NAME = "pdfbookmark"
QML_IMPORT_MAJOR_VERSION = 1


@QmlElement
class PDFBookmark(QObject):
    footerMsgChanged = Signal(str, arguments=['msg'])
    regex = re.compile(r'(\t*)\s*?(\S.*?)\s+(-?\d+)\s*')

    def __init__(self, parent: QObject | None = None) -> None:
        super().__init__(parent)
        self.__file = ''
        self.__reader: PdfReader = None

    @Property(str)
    def file(self):
        return self.__file

    @file.setter
    def file(self, _file):
        self.__file = _file

    #        try:
    #            self.__reader = PdfReader(self.__file)
    #        except Exception as e:
    #            self.footerMsgChanged.emit(str(e))

    @Property(str)
    def bookmark(self):
        try:
            self.__reader = PdfReader(self.__file)
            return self.__serialize_outline(self.__reader.outline)
        except Exception as e:
            self.footerMsgChanged.emit(str(e))

    def __serialize_outline(
        self, outline: list[Destination | list], hierarchy=0
    ) -> str:
        result = ''
        for dst in outline:
            if isinstance(dst, list):
                result += self.__serialize_outline(dst, hierarchy + 1)
            else:
                assert isinstance(dst, Destination)
                result += (
                    '\t' * hierarchy
                    + dst.title
                    + ' '
                    + str(self.__reader.get_destination_page_number(dst))
                    + '\n'
                )
        result = result.replace('\x00', '')
        return result

    @Slot(str, str, int, result=bool)
    def write(self, _file: str, outline: str, offset: int):
        try:
            self.__reader = PdfReader(self.__file)
            ofile = _file
            lines = outline.strip().split('\n')
            writer = PdfWriter()
            writer.append_pages_from_reader(self.__reader)

            parents: list[None | IndirectObject] = [None]
            for i, line in enumerate(lines):
                if line.strip() == '':
                    continue

                try:
                    prefix, title, page_num = self.regex.match(line).groups()
                except Exception as e:
                    raise Exception(f'Invalid bookmark at line "{line}"')
                hierarchy = prefix.count('\t') + 1
                if len(parents) < hierarchy + 1:
                    parents.append(None)
                parents[hierarchy] = writer.add_outline_item(
                    title=title,
                    page_number=int(page_num) + offset,
                    parent=parents[hierarchy - 1],
                )

            writer.write(ofile)
            return True
        except Exception as e:
            self.footerMsgChanged.emit(str(e))
            return False
