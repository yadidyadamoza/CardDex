//
//  ContentView.swift
//  CardDex
//
//  Created by Yedidya Damoza on 29/07/2026.
//

import SwiftUI

struct ContentView: View {
    
    @State private var pokemonName = ""
    var body: some View {
        NavigationStack{
            VStack{
                Text("Pokémon Card Dex")
                    .font(.title)
                    .bold(true)
                    .padding()
                Image("PokemonLogo")
                    .resizable()
                    .frame(width: 280, height: 100)
                    .padding(.bottom)
                HStack{
                    Image(systemName: "magnifyingglass")
                    
                    TextField("Pokémon Name", text: $pokemonName)
                }
                .padding(.bottom)
                .frame(width: 300, height: 50)
                .background(Color.gray.opacity(0.15))
                .cornerRadius(10)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding()
                VStack{
                    NavigationLink{
                        FirstView(pokemonName: pokemonName.trimmingCharacters(in: .whitespacesAndNewlines))
                        
                            
                        }label: {
                            Text("Search")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(width: 300, height: 50)
                                .background(Color.blue)
                                .cornerRadius(20)
                                .shadow(radius: 4)
                        }

                        Image("TeamRocket")
                            .resizable()
                            .frame(width: 350, height: 300)
                        Spacer()
                        
                        Text("Developed by Yedidya Damoza © 2026")
                            .font(.caption)
                            .foregroundStyle(.gray)
                    }
                
            }
            Spacer()
            
        }
        
        
    }
}

struct FirstView: View {
    
    let pokemonName: String
    @State private var cards: [PokemonCard] = []
    
    @State private var isLoading = true
    
    
    
    func getCards(pokemonName: String) throws -> [PokemonCard] {
        
        guard let url = Bundle.main.url(forResource: "cards", withExtension: "json") else{
            throw PokemonError.invalidURL
        }
        
        let data = try Data(contentsOf: url)
        let response = try JSONDecoder().decode(PokemonCardResponse.self, from: data)
        
        let filteredCards = response.data.filter { card in card.name.lowercased() == pokemonName.lowercased()
        }
        
        if filteredCards.isEmpty{
            throw PokemonError.noCardsFound
        }
        return filteredCards
        
    }
    
    var body: some View {
        ScrollView{
            VStack{
                if cards.isEmpty{
                    Rectangle()
                        .fill(Color.gray)
                        .frame(width: 250, height: 350)
                        .overlay {
                            Text("Card not found")
                                .foregroundColor(.black)
                        }
                }
                else{
                    ForEach(cards) { card in
                        VStack{
                            
                            let url = card.images?.large?.trimmingCharacters(in: .whitespacesAndNewlines)
                            
                            AsyncImage(url: URL(string: url ??  "")) { phase in switch phase {
                                case .empty:
                                ProgressView()
                                
                                case.success(let image):
                                    image
                                        .resizable()
                                        .scaledToFit( )
                                
                                case .failure(let error):
                                    VStack{
                                        Text("Error loading image")
                                        Text(error.localizedDescription)
                                            .font(.caption)
                                            .multilineTextAlignment(.center)
                                    }
                                @unknown default:
                                    EmptyView()
                                }
                            }
                            .frame(width: 250, height: 350)
                            
                            
                            Text(card.name)
                                .font(.title)
                                .bold()
                            
                            
                            Text("HP: \(card.hp ?? "Unknown")")
                            
                            
                            Text("Type: \(card.types?.joined(separator: ", " ) ?? "Unknown")")
                            
                            
                            Text("Rarity: \(card.rarity ?? "Unknown")")
                            
                            Text("Release: \(card.set.releaseDate)")
                            
                            Text("Price: \(card.cardmarket?.prices?.averageSellPrice.map{ "\($0)$"} ?? "Unknown")")
                                .font(.title3)
                                .foregroundColor(.green)
                                .font(.callout)
                                                
                            
                        }
                        .padding()
                    }
                }
            }
        }
        .task {
            do {
                cards = try getCards(pokemonName: pokemonName)
            }catch {
                print(error)
            }
            isLoading = false
        }
    }
}


#Preview {
    ContentView()
}

struct PokemonCardResponse: Codable {
    let data: [PokemonCard]
}

struct CardImages: Codable {
    let small: String?
    let large: String?
}

struct PokemonSet: Codable {
    let name: String
    let releaseDate: String
}

struct CardMarket: Codable {
    let prices: CardPrice?
}
struct CardPrice: Codable {
    let averageSellPrice: Double?
}

struct PokemonCard: Codable, Identifiable {
    let id: String
    let name: String
    let hp: String?
    let types: [String]?
    let rarity: String?
    let images: CardImages?
    let set: PokemonSet
    let cardmarket: CardMarket?
}

enum PokemonError: Error{
    case invalidURL
    case noCardsFound
    case networkError
    case decodingError
}
