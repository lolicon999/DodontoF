#--*-coding:utf-8-*--

module DodontoF
  # Image情報
  class Image
    def initialize(server, saveDirInfo)
      @logger = DodontoF::Logger.instance
      @server = server
      @saveDirInfo = saveDirInfo
    end

    def deleteImage(params)
      @logger.debug("deleteImage begin")

      @logger.debug(params, "imageData")

      imageUrlList = params['imageUrlList']
      @logger.debug(imageUrlList, "imageUrlList")

      deleteImages(imageUrlList)
    end

    def deleteImages(imageUrlList)
      imageFiles = @server.getAllImageFileNameFromTagInfoFile()
      @server.addLocalImageToList(imageFiles)
      @logger.debug(imageFiles, "imageFiles")

      imageUrlFileName = $imageUrlText
      @logger.debug(imageUrlFileName, "imageUrlFileName")

      deleteCount = 0
      resultText = ""
      imageUrlList.each do |imageUrl|
        if( @server.isProtectedImage(imageUrl) )
          warningMessage = "#{imageUrl}は削除できない画像です。"
          next
        end

        imageUrl.untaint
        deleteResult1 = @server.deleteImageTags(imageUrl)
        deleteResult2 = @server.deleteTargetImageUrl(imageUrl, imageFiles, imageUrlFileName)
        deleteResult = (deleteResult1 or deleteResult2)

        if( deleteResult )
          deleteCount += 1
        else
          warningMessage = "不正な操作です。あなたが削除しようとしたファイル(#{imageUrl})はイメージファイルではありません。"
          @logger.error(warningMessage)
          resultText += warningMessage
        end
      end

      resultText += "#{deleteCount}個のファイルを削除しました。"
      result = {"resultText" => resultText}
      @logger.debug(result, "result")

      @logger.debug("deleteImage end")
      return result
    end
  end
end
