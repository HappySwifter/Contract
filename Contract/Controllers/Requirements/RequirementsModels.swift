//
//  RequirementsModels.swift
//  SmartContrakt
//
//  Created by Артем Валиев on 04/12/2018.
//  Copyright (c) 2018 Артем Валиев. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

enum Requirements
{
  // MARK: Use cases
  
  enum Something
  {
    struct Request
    {
    }
    struct Response
    {
        let requirements: [RequirementModel]
    }
    struct ViewModel
    {
        let requirements: [RequirementModel]
    }
  }
    
    enum SetRequirement
    {
        struct Request
        {
            /// если требование серверное, то id будет присутствовать
            let requirementId: String?
            let requirementText: String
            let yesNo: Bool
            let note: String?
        }
        
        struct Response
        {
        }
        struct ViewModel
        {
        }
    }
    
    enum DeleteRequirement
    {
        struct Request
        {
            let requirementId: String
        }
        
        struct Response
        {
        }
        struct ViewModel
        {
        }
    }
}
