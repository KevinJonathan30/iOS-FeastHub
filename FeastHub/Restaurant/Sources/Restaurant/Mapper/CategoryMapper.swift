//
//  CategoryMapper.swift
//  FeastHub
//
//  Created by Kevin Jonathan on 11/12/22.
//

import Foundation
import RealmSwift

public class CategoryMapper {
    
    // MARK: Response to Model
    
    public static func mapCategoryResponseListToModelList(
        input categoryResponseList: [CategoryResponse]
    ) -> [CategoryModel] {
        return categoryResponseList.map { result in
            var categoryModel = CategoryModel()
            categoryModel.name = result.name ?? ""
            return categoryModel
        }
    }
    
    // MARK: Entity to Model
    
    public static func mapCategoryEntityListToModelList(
        input categoryEntities: RealmSwift.List<CategoryEntity>
    ) -> [CategoryModel] {
        return categoryEntities.map { result in
            return CategoryModel(name: result.name ?? "")
        }
    }
    
    // MARK: Model to Entity
    
    public static func mapCategoryModelListToEntityList(
        input categoryModelList: [CategoryModel]
    ) -> RealmSwift.List<CategoryEntity> {
        let categoryEntityList = List<CategoryEntity>()
        
        for category in categoryModelList {
            let categoryEntity = CategoryEntity()
            categoryEntity.name = category.name
            categoryEntityList.append(categoryEntity)
        }
        
        return categoryEntityList
    }
}
