//
//  HomeViewModel.swift
//  Chefaa
//
//  Created by KarimEbrahem on 9/8/20.
//  Copyright © 2020 KarimEbrahem. All rights reserved.
//

import Foundation
import Domain
import RxSwift
import RxCocoa

typealias HomeComponentsViewModelsTypeAlias = (sliders: [SliderItemViewModel], subCategories: [SubCategoryItemViewModel], brands: [BrandItemViewModel], bestSellingItems: [BestSellingItemViewModel], landingPages: [LandingPageItemViewModel])

final class HomeViewModel: ViewModelType {
    
    struct Input {
        let trigger: Driver<Void>
    }
    struct Output {
        let fetching: Driver<Bool>
        let homeAds: Driver<HomeComponentsViewModelsTypeAlias>
        let error: Driver<Error>
    }
    
    private let useCase: AdvertisementsUseCase
    
    init(useCase: AdvertisementsUseCase) {
        self.useCase = useCase
    }
    
    func transform(input: Input) -> Output {
        let activityIndicator = ActivityIndicator()
        let errorTracker = ErrorTracker()
        
        let homeComponents = input.trigger.flatMapLatest {
            return self.useCase.homeComponents()
                .trackActivity(activityIndicator)
                .trackError(errorTracker)
                .asDriverOnErrorJustComplete()
                .map { (homeItems: HomeComponentsTypeAlias) -> HomeComponentsViewModelsTypeAlias in
                    
                    let sliderItemsViewModels = homeItems.sliders.map { SliderItemViewModel(with: $0) }
                    let subCategoriesItemsViewModels = homeItems.subCategories.map { SubCategoryItemViewModel(with: $0) }
                    let brandsItemsViewModels = homeItems.brands.map { BrandItemViewModel(with: $0) }
                    let bestSellingItemsViewModels = homeItems.items.map { BestSellingItemViewModel(with: $0) }
                    let landingPagesItemsViewModels = homeItems.landingPages.map { LandingPageItemViewModel(with: $0) }
                    
                    return (sliders: sliderItemsViewModels,
                            subCategories: subCategoriesItemsViewModels,
                            brands: brandsItemsViewModels,
                            bestSellingItems: bestSellingItemsViewModels,
                            landingPages: landingPagesItemsViewModels)
            }
        }
        
        let fetching = activityIndicator.asDriver()
        let errors = errorTracker.asDriver()
        
        return Output(fetching: fetching,
                      homeAds: homeComponents,
                      error: errors)
    }
}
