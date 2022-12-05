import random

from textual.app import App, ComposeResult
from textual.color import Color
from textual.widgets import Footer, Static

from textual_mastodon.bar import Bar


class Dock(Static):
    CSS = """Dock {
    dock: left;
    width: 15;
    height: 100 %;
    color:  # 0f2b41;
    background: dodgerblue;
    }   
    """

class BindingApp(App):
    BINDINGS = [
        ("r", "add_bar('red')", "Add Red"),
        ("g", "add_bar('green')", "Add Green"),
        ("b", "add_bar('blue')", "Add Blue"),
        ("q", "quit()", "quit")
    ]

    def quit(self):
        self.action_quit()

    def compose(self) -> ComposeResult:
        yield Dock()
        yield Footer()

    def action_add_bar(self, color: str) -> None:
        bar = Bar(color)
        bar.styles.background = Color.parse(color).with_alpha(random.random())
        self.mount(bar)
        self.call_after_refresh(self.screen.scroll_end, animate=False)


if __name__ == "__main__":
    app = BindingApp()
    app.run()
