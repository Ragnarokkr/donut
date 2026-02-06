# Runs WinUtil tools by Chris Titus via PowerShell
def winutil [] {
  pwsh.exe -Command "irm christitus.com/win | iex"
}
