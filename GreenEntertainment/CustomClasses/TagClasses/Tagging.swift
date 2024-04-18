import UIKit
import Foundation

open class Tagging: UIView, UITableViewDelegate, UITableViewDataSource {

    // MARK: - Apperance
    open var cornerRadius: CGFloat {
        get { return textView.layer.cornerRadius }
        set { textView.layer.cornerRadius = newValue }
    }
    
    open override var borderWidth: CGFloat {
        get { return textView.layer.borderWidth }
        set { textView.layer.borderWidth = newValue }
    }
    
    open override var borderColor: UIColor? {
        get { return UIColor(cgColor: textView.layer.borderColor ?? UIColor.black.cgColor) }
        set { textView.layer.borderColor = newValue?.cgColor }
    }
    
    
    
    open var textInset: UIEdgeInsets {
        get { return textView.textContainerInset }
        set { textView.textContainerInset = newValue }
    }
    
    override open var backgroundColor: UIColor? {
        get { return textView.backgroundColor }
        set { textView.backgroundColor = newValue }
    }
    
    // MARK: - Properties
    
    open var symbol: String = ""
    open var atSymbol: String = "@"
    open var hashSymbol: String = "#"
    open var tagableList: [String]?
    open var hashtagTaggableList: [String]?
    open var atTaggableList: [String]?

    open var defaultAttributes: [NSAttributedString.Key: Any] = {
        return [NSAttributedString.Key.foregroundColor: UIColor.black,
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 15),
                NSAttributedString.Key.underlineStyle: NSNumber(value: 0)]
    }()
    open var symbolAttributes: [NSAttributedString.Key: Any] = {
        return [NSAttributedString.Key.foregroundColor: UIColor.black,
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 15),
                NSAttributedString.Key.underlineStyle: NSNumber(value: 0)]
    }()
    open var taggedAttributes: [NSAttributedString.Key: Any] = {return [NSAttributedString.Key.underlineStyle: NSNumber(value: 1)]}()
    
    public private(set) var taggedList: [TaggingModel] = []
    public weak var dataSource: TaggingDataSource?
    
    var matchedTagableList = [String]()
    private var currentTaggingText: String? {
        didSet {
            guard let currentTaggingText = currentTaggingText, let tagableList = tagableList else {return}
            print("currentTaggingText:-\(currentTaggingText)")
            matchedTagableList = tagableList.filter {
                $0.lowercased().contains(currentTaggingText.lowercased()) || $0.uppercased().contains(currentTaggingText.uppercased())
            }
            print("matchedTagableList:-\(String(describing: matchedTagableList.first))")
            dataSource?.tagging(self, didChangedTagableList: matchedTagableList)
        }
    }
    private var currentTaggingRange: NSRange?
    private var tagRegex: NSRegularExpression! {return try! NSRegularExpression(pattern: "([\(symbol)])([^\\s\\K]+)")}
    private let tableView = UITableView()

    // MARK: - UI Components
    
    public let textView: UITextView = {
        var textView = UITextView()
        textView.text =  "Add Caption"
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    // MARK: - Con(De)structor
    
    public init() {
        super.init(frame: .zero)
        commonSetup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonSetup()
    }
    
    // MARK: - Public methods
    
    public func updateTaggedList(allText: String, tagText: String) {
        guard let range = currentTaggingRange else {return}
        
        let origin = (allText as NSString).substring(with: range)
        let tag = tagFormat(tagText)
        let replace = tag.appending(" ")
        let changed = (allText as NSString).replacingCharacters(in: range, with: replace)
        let tagRange = NSMakeRange(range.location, tag.utf16.count)
        
        taggedList.append(TaggingModel(text: tagText, range: tagRange))
        for i in 0..<taggedList.count-1 {
            var location = taggedList[i].range.location
            let length = taggedList[i].range.length
            if location > tagRange.location {
                location += replace.count - origin.count
                taggedList[i].range = NSMakeRange(location, length)
            }
        }
        
        textView.text = changed
        updateAttributeText(selectedLocation: range.location+replace.count)
        dataSource?.tagging(self, didChangedTaggedList: taggedList)
    }
    
    // MARK: - Private methods
    
    private func commonSetup() {
        setProperties()
        addSubview(textView)
        addSubview(tableView)
        tableView.isHidden = true
        tableView.delegate = self
        tableView.dataSource = self
        layout()
    }
    
    private func setProperties() {
        backgroundColor = .clear
        textView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

    }
    
    private func tagFormat(_ text: String) -> String {
        return symbol.appending(text)
    }
    
}

// MARK: - Layout

extension Tagging {
    
    private func layout() {
        addConstraints(
            [NSLayoutConstraint(item: textView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0),
             NSLayoutConstraint(item: textView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0),
             NSLayoutConstraint(item: textView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0),
             NSLayoutConstraint(item: textView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0)])
    }

}

// MARK: - UITextViewDelegate

extension Tagging: UITextViewDelegate {
        
       public func textViewDidBeginEditing(_ textView: UITextView) {
           if textView.text == "Add Caption" {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text =  "Add Caption"
            textView.textColor = UIColor.lightGray
        }
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        tagging(textView: textView)
        
        updateAttributeText(selectedLocation: textView.selectedRange.location)
    }
    
    public func textViewDidChangeSelection(_ textView: UITextView) {
        tagging(textView: textView)
    }
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        if newText.count == 1 && (newText == "@" || newText == "#") {
            symbol = newText
        }
        let numberOfChars = newText.count <= 100
        let textWidth = Double(textView.frame.size.width - 2.0 * textView.textContainer.lineFragmentPadding)
        let boundingRect = sizeOfString(string: newText, constrainedToWidth: textWidth, font: textView.font!)
        let numberOfLines = Int(boundingRect.height / textView.font!.lineHeight)
        
        print("newText:-\(newText) && text\(text) && Count = \(newText.count)")

        updateTaggedList(range: range, textCount: text.utf16.count)

        return numberOfLines <= 3 && newText.count <= 100
    }
    
    func sizeOfString (string: String, constrainedToWidth width: Double, font: UIFont) -> CGSize {
        return (string as NSString).boundingRect(with: CGSize(width: width, height: Double.greatestFiniteMagnitude),
                                                 options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                                 attributes: [NSAttributedString.Key.font: font],
                                                 context: nil).size
    }

    
    /*public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)

        
        print("newText:-\(newText) && text\(text) && Count = \(newText.count)")

       updateTaggedList(range: range, textCount: text.utf16.count)
        return newText.count <= 100
      //  return true
    }*/
    
}

// MARK: - Tagging Algorithm

extension Tagging {
    
    private func matchedData(taggingCharacters: [Character], selectedLocation: Int, taggingText: String) -> (NSRange?, String?) {
        var matchedRange: NSRange?
        var matchedString: String?
        let tag = String(taggingCharacters.reversed())
        let textRange = NSMakeRange(selectedLocation-tag.count, tag.count)
        
        guard tag == symbol else {
            let matched = tagRegex.matches(in: taggingText, options: .reportCompletion, range: textRange)
            if matched.count > 0, let range = matched.last?.range {
                matchedRange = range
                matchedString = (taggingText as NSString).substring(with: range).replacingOccurrences(of: symbol, with: "")
            }
            return (matchedRange, matchedString)
        }
        
        matchedRange = textRange
        matchedString = symbol
        return (matchedRange, matchedString)
    }
    
    private func tagging(textView: UITextView) {
        let selectedLocation = textView.selectedRange.location
        let taggingText = (textView.text as NSString).substring(with: NSMakeRange(0, selectedLocation))
        let space: Character = " "
        let lineBrak: Character = "\n"
        var tagable: Bool = false
        var characters: [Character] = []
        
        for char in Array(taggingText).reversed() {
            if char == symbol.first {
                characters.append(char)
                tagable = true
                break
            } else if char == space || char == lineBrak {
                tagable = false
                break
            }
            characters.append(char)
        }
        
        guard tagable else {
            currentTaggingRange = nil
            currentTaggingText = nil
            return
        }
        
        let data = matchedData(taggingCharacters: characters, selectedLocation: selectedLocation, taggingText: taggingText)
        currentTaggingRange = data.0
        currentTaggingText = data.1
        
        let firstCharacter = String(taggingText.first ?? Character(""))
        if textView.text.isEmpty || (!taggingText.contains(atSymbol) && !taggingText.contains(hashSymbol)) {
            tableView.isHidden = true
        } else if firstCharacter == atSymbol {
            symbol = atSymbol
            tagableList = atTaggableList
        } else if firstCharacter == hashSymbol {
            symbol = hashSymbol
            tagableList = hashtagTaggableList
        }

        
        if tagable {
            tableView.isHidden = false
            tableView.reloadData()
        } else {
            tableView.isHidden = true
        }
    }
    
    private func updateAttributeText(selectedLocation: Int) {
        let attributedString = NSMutableAttributedString(string: textView.text)
        attributedString.addAttributes(defaultAttributes, range: NSMakeRange(0, textView.text.utf16.count))
        taggedList.forEach { (model) in
            let symbolAttributesRange = NSMakeRange(model.range.location, symbol.count)
            let taggedAttributesRange = NSMakeRange(model.range.location+1, model.range.length-1)
            
            attributedString.addAttributes(symbolAttributes, range: symbolAttributesRange)
            attributedString.addAttributes(taggedAttributes, range: taggedAttributesRange)
        }
        
        textView.attributedText = attributedString
        textView.selectedRange = NSMakeRange(selectedLocation, 0)
    }
    
    private func updateTaggedList(range: NSRange, textCount: Int) {
        taggedList = taggedList.filter({ (model) -> Bool in
            if model.range.location < range.location && range.location < model.range.location+model.range.length {
                return false
            }
            if range.length > 0 {
                if range.location <= model.range.location && model.range.location < range.location+range.length {
                    return false
                }
            }
            return true
        })
        
        for i in 0..<taggedList.count {
            var location = taggedList[i].range.location
            let length = taggedList[i].range.length
            if location >= range.location {
                if range.length > 0 {
                    if textCount > 1 {
                        location += textCount - range.length
                    } else {
                        location -= range.length
                    }
                } else {
                    location += textCount
                }
                taggedList[i].range = NSMakeRange(location, length)
            }
        }
        
        currentTaggingText = nil
        dataSource?.tagging(self, didChangedTaggedList: taggedList)
        tableView.isHidden = true

    }
    
    // MARK: - UITableViewDelegate
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let currentTaggingRange = currentTaggingRange else {
            return
        }
        
        let selectedTag = matchedTagableList[indexPath.row]
        
        updateTaggedList(range: currentTaggingRange, textCount: textView.text.count)
        updateTaggedList(allText: textView.text, tagText: selectedTag)
        tableView.isHidden = true
    }

    
    // MARK: - UITableViewDataSource
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchedTagableList.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = matchedTagableList[indexPath.row]
        return cell
    }
}
