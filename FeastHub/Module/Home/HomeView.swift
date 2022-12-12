//
//  HomeView.swift
//  FeastHub
//
//  Created by Kevin Jonathan on 11/12/22.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var presenter: HomePresenter
    
    var body: some View {
        ZStack {
            switch presenter.viewState {
            case .loading:
                loadingIndicator()
            case .fail:
                errorIndicator()
            case .empty:
                emptyRestaurants()
            case .loaded:
                content()
            }
        }
        .navigationBarTitle("FeastHub")
        .onAppear {
            if self.presenter.restaurants.isEmpty {
                self.presenter.getRestaurantList()
            }
        }
        .refreshable {
            self.presenter.getRestaurantList()
        }
    }
}

// MARK: ViewBuilder

extension HomeView {
    @ViewBuilder
    func loadingIndicator() -> some View {
        VStack {
            Text("Loading...")
            ProgressView()
        }
    }
    
    @ViewBuilder
    func errorIndicator() -> some View {
        CustomEmptyView(
            image: "assetSearchNotFound",
            title: presenter.errorMessage
        ).offset(y: 80)
    }
    
    @ViewBuilder
    func emptyRestaurants() -> some View {
        CustomEmptyView(
            image: "assetNoFavorite",
            title: "The restaurant is empty"
        ).offset(y: 80)
    }
    
    @ViewBuilder
    func content() -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack {
                ForEach(
                    self.presenter.restaurants,
                    id: \.id
                ) { restaurant in
                    ZStack {
                        self.presenter.linkBuilder(for: restaurant) {
                            RestaurantCard(restaurant: restaurant)
                        }.buttonStyle(PlainButtonStyle())
                    }.padding(8)
                }
            }
        }
    }
}
