//
//  Bundle-Decodable.swift
//  Moonshot
//
//  Created by Khanh Nguyen Quoc on 13/3/25.
//

import Foundation

extension Bundle {
    // note to self: this will still crash the app when error occur, but it will tell what went wrong
    func decode<T: Decodable>(_ file: String) -> T {
        guard let url = self.url(forResource: file, withExtension: nil) else {
            fatalError("Failed to locate \(file) in bundle.")
        }
        
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load \(file) from bundle.")
        }
        
        let decoder = JSONDecoder()
        
        // apparently this block of code can auto format date from JSON and turn into Date?
        let formatter = DateFormatter()
        formatter.dateFormat = "y-MM-dd"
        decoder.dateDecodingStrategy = .formatted(formatter)
        
        //        guard let loaded = try? decoder.decode(T.self, from: data) else {
        //            fatalError("Failed to decode \(file) from bundle.")
        //        }
        //        return loaded
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch DecodingError.keyNotFound(let key, let context) {
            fatalError("Failed to decode \(file) due to missing key: \(key.stringValue) - \(context.debugDescription)")
        } catch DecodingError.typeMismatch(_, let context) {
            fatalError("Failed to decode \(file) due to type mismatch - \(context.debugDescription)")
        } catch DecodingError.valueNotFound(let type, let context) {
            fatalError("Failed to decode \(file) due to missing \(type) - \(context.debugDescription)")
        } catch DecodingError.dataCorrupted(_) {
            fatalError("Failed to decode \(file) because it appears to be invalid JSON")
        } catch {
            fatalError("Failed to decode \(file) from bundle: \(error.localizedDescription)")
        }
        
    }
}

