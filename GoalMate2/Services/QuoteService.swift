class QuoteService {
    static let shared = QuoteService()
    private let url = URL(string: "https://zenquotes.io/api/random")!

    func fetchRandomQuote(completion: @escaping (Quote?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            do {
                let quotes = try JSONDecoder().decode([Quote].self, from: data)
                completion(quotes.first)
            } catch {
                print("Decoding error:", error)
                completion(nil)
            }
        }
        task.resume()
    }
}
