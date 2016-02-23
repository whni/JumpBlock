//
//  levelParser.swift
//  ios_game_test
//
//  Created by Weiheng Ni on 2016-01-17.
//  Copyright © 2016 Weiheng Ni. All rights reserved.
//

import UIKit


struct GroundPropertyType {
    var position: CGPoint?
    var size: CGSize?
    var color: UIColor?
}

struct BlockPropertyType {
    var size: CGSize?
    var color: UIColor?
    var moveSpeed: CGVector?
    var jumpDuration: CGFloat?
    var jumpScale: CGFloat?
}

struct BarrierPropertyType {
    var position: CGPoint?
    var size: CGSize?
    var color: UIColor?
    var moveVector: CGVector?
    var moveDuration: CGFloat?
}

public struct LevelData {
    // base properties
    var levelInfoStr: String?
    var bgColor: UIColor?
    var gravity: CGVector?
    
    // game ground properties
    var groundProperty: GroundPropertyType?
    
    // game block properties
    var blockProperty: BlockPropertyType?
    
    // game barrier properties
    var barrierProperty: [BarrierPropertyType]?
    
}


public class LevelParser {
    
    private class func stringToCGFloat(string: String?) -> CGFloat {
        if string != nil {
            if let floatNumber = NSNumberFormatter().numberFromString(string!) {
                return CGFloat(floatNumber)
            }
        }
        return 0.0
    }
    
    private class func parseLevelData(jsObject: JSON) -> LevelData? {
        if jsObject.count == 0 {
            return nil
        }
        
        var levelData = LevelData()
        
        // basic property
        levelData.levelInfoStr = jsObject["levelInfo"].string
        levelData.bgColor = UIColor.UIColorFromHexString(jsObject["bgColor"].string)
        levelData.gravity = CGVectorMake(0, stringToCGFloat(jsObject["gravity"].string))
        
        // ground property
        let groundJSONData = jsObject["ground"]
        levelData.groundProperty = GroundPropertyType()
        levelData.groundProperty?.size = CGSizeMake(stringToCGFloat(groundJSONData["size"]["width"].string), stringToCGFloat(groundJSONData["size"]["height"].string))
        levelData.groundProperty?.position = CGPointMake(stringToCGFloat(groundJSONData["position"]["x"].string), stringToCGFloat(groundJSONData["position"]["y"].string))
        levelData.groundProperty?.color = UIColor.UIColorFromHexString(groundJSONData["color"].string)
        
        // block property
        let blockJSONData = jsObject["block"]
        levelData.blockProperty = BlockPropertyType()
        levelData.blockProperty?.size = CGSizeMake(stringToCGFloat(blockJSONData["size"]["width"].string), stringToCGFloat(blockJSONData["size"]["height"].string))
        levelData.blockProperty?.moveSpeed = CGVectorMake(stringToCGFloat(blockJSONData["moveSpeed"].string), 0)
        levelData.blockProperty?.jumpDuration = stringToCGFloat(blockJSONData["jumpDuration"].string)
        levelData.blockProperty?.jumpScale = stringToCGFloat(blockJSONData["jumpScale"].string)
        levelData.blockProperty?.color = UIColor.UIColorFromHexString(blockJSONData["color"].string)
        
        // barrier property
        let barrierJSONData = jsObject["barrier"]
        levelData.barrierProperty = [BarrierPropertyType](count: barrierJSONData.count, repeatedValue: BarrierPropertyType())
        for var idx = 0; idx < barrierJSONData.count; idx++ {
            levelData.barrierProperty![idx].size = CGSizeMake(stringToCGFloat(barrierJSONData[idx]["size"]["width"].string), stringToCGFloat(barrierJSONData[idx]["size"]["height"].string))
            levelData.barrierProperty![idx].position = CGPointMake(stringToCGFloat(barrierJSONData[idx]["position"]["x"].string), stringToCGFloat(barrierJSONData[idx]["position"]["y"].string))
            levelData.barrierProperty![idx].moveVector = CGVectorMake(stringToCGFloat(barrierJSONData[idx]["moveVector"]["dx"].string), stringToCGFloat(barrierJSONData[idx]["moveVector"]["dy"].string))
            levelData.barrierProperty![idx].moveDuration = stringToCGFloat(barrierJSONData[idx]["moveDuration"].string)
            levelData.barrierProperty![idx].color = UIColor.UIColorFromHexString(barrierJSONData[idx]["color"].string)
        }
            
        return levelData
    }
   
    private class func levelDataSanityCheck(levelData: LevelData?) -> Bool {
        
        if levelData == nil {return false}
        
        if levelData!.levelInfoStr   == nil {return false}
        if levelData!.bgColor        == nil {return false}
        if levelData!.gravity        == nil {return false}
        
        if levelData!.groundProperty != nil {
            if levelData!.groundProperty!.color      == nil {return false}
            if levelData!.groundProperty!.position   == nil {return false}
            if levelData!.groundProperty!.size       == nil {return false}
        } else {
            return false
        }
        
        if levelData!.blockProperty != nil {
            if levelData!.blockProperty!.color           == nil {return false}
            if levelData!.blockProperty!.size            == nil {return false}
            if levelData!.blockProperty!.moveSpeed       == nil {return false}
            if levelData!.blockProperty!.jumpDuration    == nil {return false}
            if levelData!.blockProperty!.jumpScale       == nil {return false}
        } else {
            return false
        }
        
        if levelData!.barrierProperty != nil {
            for var idx = 0; idx < levelData!.barrierProperty!.count; idx++ {
                if levelData!.barrierProperty![idx].color        == nil {return false}
                if levelData!.barrierProperty![idx].position     == nil {return false}
                if levelData!.barrierProperty![idx].size         == nil {return false}
                if levelData!.barrierProperty![idx].moveDuration == nil {return false}
                if levelData!.barrierProperty![idx].moveVector   == nil {return false}
            }
            
        } else {
            return false
        }
        
        return true
    }
    
    public class func getLevelFromJSONFile(jsFile: String) -> [LevelData?] {

        if let jsonPath = NSBundle.mainBundle().pathForResource(jsFile, ofType: "json") {
            if let jsonData = try? NSData(contentsOfFile: jsonPath, options: NSDataReadingOptions.DataReadingMappedIfSafe) {
                let jsonObject = JSON(data: jsonData)
                let jsonLevelArray = jsonObject["levelArray"]
                var levelArray = [LevelData?](count: 0, repeatedValue: nil)
                
                for var idx = 0; idx < jsonLevelArray.count; idx++ {
                    levelArray.append(parseLevelData(jsonLevelArray[idx]))
                    if levelDataSanityCheck(levelArray[levelArray.count - 1]) == false {
                        levelArray.removeLast()
                    }
                }
                
                return levelArray
            }
        }
        return []
    }
}
