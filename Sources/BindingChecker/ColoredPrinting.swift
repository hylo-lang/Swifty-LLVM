import Foundation

enum TextStyle {
  case blueUnderline
  case lightPurple
  case grey
}

func applyStyle(_ text: String, as style: TextStyle) -> String {
  let escape = "\u{001B}["
  let reset = "\(escape)0m"

  let code: String
  switch style {
  case .blueUnderline:
    code = "4;34m"  // 4 = Underline, 34 = Blue
  case .lightPurple:
    code = "95m"  // 95 = High Intensity Magenta (Light Purple)
  case .grey:
    code = "90m"  // 90 = Bright Black (looks like Grey)
  }

  return "\(escape)\(code)\(text)\(reset)"
}

func link(_ text: String) -> String {
  return applyStyle(text, as: .blueUnderline)
}

func purple(_ text: String) -> String {
  return applyStyle(text, as: .lightPurple)
}

func dark(_ text: String) -> String {
  return applyStyle(text, as: .grey)
}