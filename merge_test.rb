require 'java'
require_relative 'vendor/commons-logging-1.2.jar'
require_relative 'vendor/pdfbox-2.0.18.jar'

class PDFMerger
  java_import org.apache.pdfbox.multipdf.PDFMergerUtility

  def self.run()
    pdf_merger = PDFMergerUtility.new()

    pdf_merger.addSource("./test_materials/shippinglabel1.pdf")
    pdf_merger.addSource("./test_materials/shippinglabel2.pdf")
    pdf_merger.addSource("./test_materials/shippinglabel3.pdf")

    pdf_merger.setDestinationFileName("./output/merged_labels.pdf")

    pdf_merger.mergeDocuments(nil)
  end
end

PDFMerger.run()
