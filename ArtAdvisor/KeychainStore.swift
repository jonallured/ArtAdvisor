import Foundation

struct KeychainStore {
    static let server = "https://www.artsy.net"
    
    static func getAccessToken() -> String? {
        let query = [
            kSecClass: kSecClassInternetPassword,
            kSecAttrServer: server,
            kSecReturnAttributes: true,
            kSecReturnData: true
        ] as CFDictionary
        
        var matchingItem: CFTypeRef?
        let status = SecItemCopyMatching(query, &matchingItem)
        
        guard status == errSecSuccess else {
            let errorMessage = SecCopyErrorMessageString(status, nil)
            print(errorMessage ?? "unknown status")
            return nil
        }
                
        guard
            let itemData = matchingItem as? [CFString: Any],
            let encodedData = itemData[kSecValueData] as? Data,
            let password = String(data: encodedData, encoding: .utf8)
        else {
            print("couldn't decode data")
            return nil
        }
        
        return password
    }
    
    static func setAccessToken(_ accessToken: String, email account: String) {
        let encodedAccessToken = accessToken.data(using: .utf8)!
        
        let query = [
            kSecClass: kSecClassInternetPassword,
            kSecAttrAccount: account,
            kSecAttrServer: server,
            kSecValueData: encodedAccessToken,
        ] as CFDictionary
        
        print(query)
        
        let status = SecItemAdd(query, nil)
        
        guard status == errSecSuccess else {
            let errorMessage = SecCopyErrorMessageString(status, nil)
            print(errorMessage ?? "unknown status")
            return
        }
    }
}
