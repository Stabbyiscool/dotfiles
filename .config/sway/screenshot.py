#!/usr/bin/env python3
import os, sys, tempfile, subprocess
from uuid import uuid4
from PyQt5.QtWidgets import (
    QApplication,
    QLabel,
    QMainWindow,
    QPushButton,
    QColorDialog,
    QVBoxLayout,
    QWidget,
    QHBoxLayout,
    QStyleFactory,
    QLineEdit,
)
from PyQt5.QtGui import QPixmap, QPainter, QPen, QColor, QFontMetricsF, QFont
from PyQt5.QtCore import Qt, QPoint
import time

TEMP_DIR = tempfile.gettempdir()
TEMP_IMAGE = os.path.join(TEMP_DIR, f"screenshot_{uuid4().hex[:8]}.png")


def take_screenshot():
    freeze = subprocess.Popen(["wayfreeze"])
    time.sleep(0.2)
    region = subprocess.check_output(["slurp"]).decode().strip()
    subprocess.run(["grim", "-g", region, TEMP_IMAGE])
    freeze.terminate()
    copy_to_clipboard(TEMP_IMAGE)
    return os.path.exists(TEMP_IMAGE)

def copy_to_clipboard(path):
    with open(path, "rb") as f:
        subprocess.run(["wl-copy", "--type", "image/png"], input=f.read())


def notify(msg):
    subprocess.run(["notify-send", "screenshot", msg])


class TextBox(QLineEdit):
    def __init__(self, parent, pos, color, font_size):
        super().__init__(parent)
        self.qcolor = QColor(color)
        self.setStyleSheet(
            f"background-color: transparent; color: {self.qcolor.name()}; border: 1px dashed {self.qcolor.name()};"
        )
        self.setFontPointSize(font_size)
        self.move(pos)
        self.setFocus()
        self.parent = parent
        self.dragging = False
        self.offset = QPoint()
        self.font_size = font_size
        self.adjust_box_to_text()
        self.textChanged.connect(self.adjust_box_to_text)

    def setFontPointSize(self, size):
        font = self.font()
        font.setPointSizeF(size)
        self.setFont(font)

    def mousePressEvent(self, e):
        if e.button() == Qt.LeftButton:
            self.dragging = True
            self.offset = e.pos()
        super().mousePressEvent(e)

    def mouseMoveEvent(self, e):
        if self.dragging:
            self.move(self.mapToParent(e.pos() - self.offset))
        super().mouseMoveEvent(e)

    def mouseReleaseEvent(self, e):
        self.dragging = False
        super().mouseReleaseEvent(e)

    def focusOutEvent(self, e):
        self.commit_text()
        super().focusOutEvent(e)

    def commit_text(self):
        text = self.text()
        if not text.strip():
            self.deleteLater()
            return
        painter = QPainter(self.parent.pixmap)
        font = QFont()
        font.setPointSizeF(self.font_size)
        painter.setFont(font)
        painter.setPen(QPen(self.qcolor))
        painter.drawText(self.geometry(), Qt.AlignLeft | Qt.AlignVCenter, text)
        painter.end()
        self.parent.label.setPixmap(self.parent.pixmap)
        self.deleteLater()

    def adjust_size(self, delta):
        self.font_size = max(1, self.font_size + delta)
        self.setFontPointSize(self.font_size)
        self.adjust_box_to_text()

    def adjust_box_to_text(self):
        font = self.font()
        font.setPointSizeF(self.font_size)
        metrics = QFontMetricsF(font)
        text = self.text() or "Type here..."
        width = metrics.width(text) + 20
        height = metrics.height() + 10
        self.setFixedSize(int(width), int(height))


class BrushEditor(QMainWindow):
    def __init__(self, image_path):
        super().__init__()
        self.setWindowFlags(
            Qt.Window | Qt.WindowStaysOnTopHint | Qt.FramelessWindowHint
        )

        self.image_path = image_path
        self.pixmap = QPixmap(self.image_path)
        self.original_pixmap = self.pixmap.copy()

        self.label = QLabel()
        self.label.setPixmap(self.pixmap)
        self.label.setAlignment(Qt.AlignCenter)
        self.label.setStyleSheet("background-color: transparent;")

        self.color = Qt.white
        self.tool = "brush"
        self.brush_size = 4
        self.text_font_size = 12
        self.last_textbox = None

        self.brush_btn = QPushButton("bsh")
        self.text_btn = QPushButton("txt")
        self.color_btn = QPushButton("clr")
        for btn in [self.brush_btn, self.text_btn, self.color_btn]:
            btn.setFixedSize(36, 36)
            btn.setStyleSheet(
                "background-color: black; color: white; border: 1px solid white;"
            )

        self.brush_btn.clicked.connect(lambda: self.set_tool("brush"))
        self.text_btn.clicked.connect(lambda: self.set_tool("text"))
        self.color_btn.clicked.connect(self.pick_color)

        tool_layout = QVBoxLayout()
        tool_layout.addWidget(self.brush_btn)
        tool_layout.addWidget(self.text_btn)
        tool_layout.addWidget(self.color_btn)
        tool_layout.addStretch()

        img_layout = QHBoxLayout()
        img_layout.addWidget(self.label, 1)
        img_layout.addLayout(tool_layout)

        container = QWidget()
        container.setLayout(img_layout)
        container.setStyleSheet("background-color: black; color: white;")
        border_wrap = QWidget()
        border_layout = QVBoxLayout(border_wrap)
        border_layout.setContentsMargins(1, 1, 1, 1)
        border_layout.addWidget(container)

        border_wrap.setStyleSheet("""
            background-color: white;
        """)

        self.setCentralWidget(border_wrap)


        self.resize(self.pixmap.width() + 100, self.pixmap.height() + 50)
        self.setFixedSize(self.size())

        self.drawing = False
        self.last_point = QPoint()

    def set_tool(self, tool):
        self.tool = tool

    def pick_color(self):
        color = QColorDialog.getColor()
        if color.isValid():
            self.color = color

    def mousePressEvent(self, e):
        if e.button() == Qt.LeftButton:
            pos = self.mapToLabel(e.pos())
            if self.tool == "text":
                box = TextBox(self, pos, self.color, self.text_font_size)
                box.show()
                self.last_textbox = box
            else:
                self.drawing = True
                self.last_point = pos

    def mouseMoveEvent(self, e):
        if self.drawing and (e.buttons() & Qt.LeftButton):
            point = self.mapToLabel(e.pos())
            painter = QPainter(self.pixmap)
            if self.tool == "brush":
                pen = QPen(self.color, self.brush_size, Qt.SolidLine)
                painter.setPen(pen)
                painter.drawLine(self.last_point, point)
            painter.end()
            self.label.setPixmap(self.pixmap)
            self.last_point = point

    def mouseReleaseEvent(self, e):
        if e.button() == Qt.LeftButton:
            self.drawing = False

    def wheelEvent(self, e):
        delta = 1 if e.angleDelta().y() > 0 else -1
        if self.tool == "brush":
            self.brush_size = max(1, self.brush_size + delta)
        elif self.tool == "text" and self.last_textbox:
            self.text_font_size = max(1, self.text_font_size + delta)
            self.last_textbox.adjust_size(delta)

    def mapToLabel(self, widget_pos):
        label_pos = self.label.mapFrom(self, widget_pos)
        pixmap = self.label.pixmap()
        if not pixmap:
            return label_pos

        label_size = self.label.size()
        pixmap_size = pixmap.size()
        offset_x = max((label_size.width() - pixmap_size.width()) // 2, 0)
        offset_y = max((label_size.height() - pixmap_size.height()) // 2, 0)
        adjusted = label_pos - QPoint(offset_x, offset_y)
        return adjusted

    def closeEvent(self, event):
        self.pixmap.save(self.image_path, "PNG")
        copy_to_clipboard(self.image_path)
        notify("screenshot copied to clipboard.")
        event.accept()


def main():
    app = QApplication(sys.argv)
    app.setStyle(QStyleFactory.create("Fusion"))
    if not take_screenshot():
        notify("screenshot canceled.")
        return
    image_path = TEMP_IMAGE
    notify("screenshot taken.")

    editor = BrushEditor(image_path)
    editor.show()
    sys.exit(app.exec_())


if __name__ == "__main__":
    main()
