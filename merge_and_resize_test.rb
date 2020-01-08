require 'java'
require_relative 'vendor/commons-logging-1.2.jar'
require_relative 'vendor/fontbox-2.0.18.jar'
require_relative 'vendor/pdfbox-2.0.18.jar'

class PDFMergeAndResize
  java_import java.io.File;
  java_import org.apache.pdfbox.pdmodel.PDDocument
  java_import org.apache.pdfbox.pdmodel.PDPage
  java_import org.apache.pdfbox.pdmodel.PDPageContentStream
  java_import org.apache.pdfbox.pdmodel.common.PDRectangle
  java_import org.apache.pdfbox.pdmodel.PDResources

  def self.run()
    pd_documents = [
      PDDocument.load(File.new("./test_materials/shippinglabel1.pdf")),
      PDDocument.load(File.new("./test_materials/shippinglabel2.pdf")),
      PDDocument.load(File.new("./test_materials/shippinglabel3.pdf"))
    ]

    pdf_images = pd_documents.map {|pd_doc| get_biggest_image(pd_doc)}

    new_pdf = PDDocument.new()
    
    pdf_images.each do |image|
      new_page = PDPage.new(PDRectangle::A6)
      new_pdf.add_page(new_page)

      scaled_dimensions = get_scaled_image_dimensions(image, new_page)
      content_stream = PDPageContentStream.new(new_pdf, new_page, true, false)
      content_stream.drawXObject(image, 1, 1, scaled_dimensions[:width], scaled_dimensions[:height])
      content_stream.close()
    end

    new_pdf.save("./output/resized_merged_labels.pdf")
  end

  def self.get_biggest_image(pd_document)
    pages = pd_document.getPages()

    pdf_images = []

    pages.each do |page|
      pd_resources = page.getResources()
  
      pd_resources.getXObjectNames().each do |cos_name|
        pdx_object = pd_resources.getXObject(cos_name)
        if pdx_object.instance_of? Java::OrgApachePdfboxPdmodelGraphicsImage::PDImageXObject          
          pdf_images << pdx_object
        end
      end
    end

    pdf_images.sort_by {|image| -1 * image.getWidth() * image.getHeight()}.first
  end

  def self.get_scaled_image_dimensions(x_image, page)
    original_width = x_image.getWidth()
    original_height = x_image.getHeight()
    media_box = page.getMediaBox()
    bound_width = media_box.getWidth()
    bound_height = media_box.getHeight()

    largest_relative_image_axis =
      if (original_width / bound_width) > (original_height / bound_height)
        :width
      else
        :height
      end

    case largest_relative_image_axis
    when :width
      new_width = bound_width
      new_height = (new_width * original_height) / original_width
    when :height
      new_height = bound_height
      new_width = (new_height * original_width) / original_height
    end

    {
      width: new_width,
      height: new_height
    }
  end
end

PDFMergeAndResize.run()
