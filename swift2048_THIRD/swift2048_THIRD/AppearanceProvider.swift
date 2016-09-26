//
//  AppearanceProvider.swift
//  swift2048_THIRD
//
//  Created by jansti on 16/9/26.
//  Copyright © 2016年 jansti. All rights reserved.
//

import UIKit

protocol AppearanceProviderProtocol: class {
    func tileColor(_ value: Int) -> UIColor
    func numberColor(_ value: Int) -> UIColor
    func fontForNumbers() -> UIFont
}































