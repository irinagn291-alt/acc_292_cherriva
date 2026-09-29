import Foundation

/// Bundled Courtauld rows. Catch empty or failed search. Seed reads from here.
enum CourtauldShelf {
    static func works(daykey: Int) -> [Work] {
        rows.map { row in
            let field = Work.pickField(maker: row.maker, title: row.title) ?? .title
            return Work(
                identity: row.accession,
                objectID: row.qid,
                maker: row.maker,
                title: row.title,
                imageFile: row.file,
                thumbURL: Work.commonsThumb(file: row.file),
                fold: .idle,
                chosenField: field,
                daykey: daykey
            )
        }
    }

    private struct Row {
        let accession: String
        let qid: String
        let maker: String
        let title: String
        let file: String
    }

    private static let rows: [Row] = [
        Row(
            accession: "P.1932.SC.193",
            qid: "Q1889113",
            maker: "Edouard Manet",
            title: "A Bar at the Folies Bergere",
            file: "Edouard Manet, A Bar at the Folies-Bergère.jpg"
        ),
        Row(
            accession: "P.1932.SC.234",
            qid: "Q18688318",
            maker: "Vincent van Gogh",
            title: "Self Portrait with Bandaged Ear",
            file: "Vincent van Gogh - Self-portrait with bandaged ear (1889, Courtauld Institute).jpg"
        ),
        Row(
            accession: "P.1932.SC.150",
            qid: "Q18689452",
            maker: "Paul Cezanne",
            title: "The Card Players",
            file: "Les Joueurs de cartes, par Paul Cézanne.jpg"
        ),
        Row(
            accession: "P.1948.SC.180",
            qid: "Q18688341",
            maker: "Pierre Auguste Renoir",
            title: "La Loge",
            file: "Pierre-Auguste Renoir, La Loge, Courtauld Gallery.jpg"
        ),
        Row(
            accession: "P.1932.SC.162",
            qid: "Q18688358",
            maker: "Paul Gauguin",
            title: "Nevermore",
            file: "Paul Gauguin 091.jpg"
        ),
        Row(
            accession: "P.1948.SC.210",
            qid: "Q18689480",
            maker: "Georges Seurat",
            title: "Young Woman Powdering Herself",
            file: "Young Woman Powdering Herself Georges Seurat.jpg"
        )
    ]
}
