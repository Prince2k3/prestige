import Foundation

extension String {
    func snakeCased() -> String {
        let pattern = "([a-z0-9])([A-Z])"
        guard
            let regex = try? NSRegularExpression(pattern: pattern, options: [])
            else { return self }
        
        let template = "$1_$2"
        let range = NSRange(location: 0, length: self.count)
        let string = regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: template)
        return string.lowercased()
    }
}
