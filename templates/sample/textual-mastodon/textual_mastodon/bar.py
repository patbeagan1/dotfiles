from textual.widgets import Static


class Bar(Static):
    CSS = """
    Bar {
    height: 5;    
    content-align: center middle;
    text-style: bold;
    margin: 1 2;
    color: $text;
    }"""
    pass
