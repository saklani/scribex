import Foundation
import Testing
@testable import ScribeXCore

struct SnippetsTests {
    @Test func countsFlowIntoTheTable() {
        let best = suggest("put a 3 by 4 table here")[0]
        #expect(best.id == "table")
        #expect(best.title == "Insert a table — 3 columns × 4 rows")
        // \begin, top rule, header row, rule, four body rows, bottom rule, \end.
        #expect(best.text.components(separatedBy: "\n").count == 10)
        #expect(best.text.hasSuffix("\\end{tabular}\(caret)"))
    }

    @Test func thePlainReadingWinsATie() {
        #expect(suggest("a table").prefix(2).map(\.id) == ["table", "booktabs"])
        #expect(suggest("booktabs table")[0].id == "booktabs")
    }

    @Test func fillerWordsMatchNothing() {
        #expect(tokenize("Please put the thing here") == ["thing"])
        #expect(suggest("please put some here").isEmpty)
        // Two letters is a word: "it" reaches itemize and italic by prefix.
        #expect(suggest("put it here").map(\.id).contains("italic"))
    }

    @Test func selectionVariantsNeedASelection() {
        #expect(!suggest("turn into table").contains { $0.id == "wrap-table" })
        #expect(suggest("turn into table", hasSelection: true).contains { $0.id == "wrap-table" })
        #expect(suggest("bold", hasSelection: true)[0].title == "Set the selection in bold")
    }

    @Test func aSelectionIsWrappedWhereTheSnippetHasRoom() {
        #expect(insertion(of: "\\textbf{\(caret)}") == ("\\textbf{}", 8))
        #expect(insertion(of: "\\textbf{\(caret)}", over: "très") == ("\\textbf{très}", 12))
        // Nothing follows the marker, or there is none: the selection is replaced.
        #expect(insertion(of: "\\newpage\(caret)", over: "gone") == ("\\newpage", 8))
        #expect(insertion(of: "a & b", over: "gone") == ("a & b", 5))
    }

    @Test func selectionToTableReadsCommasAndTabs() {
        #expect(selectionToTable("a, b\nc") == "\\begin{tabular}{ll}\n  \\hline\n  a & b \\\\\n  c &  \\\\\n  \\hline\n\\end{tabular}")
        #expect(selectionToTable("a\tb\tc")?.hasPrefix("\\begin{tabular}{lll}") == true)
        #expect(selectionToTable("just one column\nhere") == nil)
        #expect(selectionToTable("  \n ") == nil)
    }
}
