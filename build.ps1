pyinstaller -wy --add-data 'main.qml;.'-n pdfbookmark-qt ./main.py

rm -Force -Recurse "dist\pdfbookmark-qt\PySide6\Qt6WebEngineCore.dll"
rm -Force -Recurse "dist\pdfbookmark-qt\PySide6\qml\QtQuick3D"
rm -Force -Recurse "dist\pdfbookmark-qt\PySide6\qml\Qt3D"
rm -Force -Recurse "dist\pdfbookmark-qt\PySide6\translations"
rm -Force -Recurse "dist\pdfbookmark-qt\PySide6\Qt6Widgets.dll"
rm -Force -Recurse "dist\pdfbookmark-qt\PySide6\Qt6Pdf.dll"
rm -Force -Recurse "dist\pdfbookmark-qt\PySide6\Qt6Quick3DRuntimeRender.dll"

$compress = @{
    Path = 'dist/pdfbookmark-qt'
    CompressionLevel = 'Optimal'
    Destination = 'dist/pdfbookmark-qt.zip'
}
Compress-Archive @compress