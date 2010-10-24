=begin
** Form generated from reading ui file 'library.ui'
**
** Created: Sun Oct 24 15:39:17 2010
**      by: Qt User Interface Compiler version 4.6.3
**
** WARNING! All changes made in this file will be lost when recompiling ui file!
=end

class Ui_LibraryWindow
    attr_reader :gridLayout_2
    attr_reader :groupBox
    attr_reader :verticalLayout_2
    attr_reader :viewActions
    attr_reader :horizontalLayout
    attr_reader :backToLibraries
    attr_reader :verticalSpacer
    attr_reader :viewLibrary
    attr_reader :tabPreferences
    attr_reader :gridLayout_3
    attr_reader :viewPreferences
    attr_reader :tabPreview
    attr_reader :gridLayout
    attr_reader :viewPreview

    def setupUi(libraryWindow)
    if libraryWindow.objectName.nil?
        libraryWindow.objectName = "libraryWindow"
    end
    libraryWindow.resize(764, 571)
    @gridLayout_2 = Qt::GridLayout.new(libraryWindow)
    @gridLayout_2.objectName = "gridLayout_2"
    @gridLayout_2.sizeConstraint = Qt::Layout::SetDefaultConstraint
    @groupBox = Qt::GroupBox.new(libraryWindow)
    @groupBox.objectName = "groupBox"
    @sizePolicy = Qt::SizePolicy.new(Qt::SizePolicy::Maximum, Qt::SizePolicy::Preferred)
    @sizePolicy.setHorizontalStretch(0)
    @sizePolicy.setVerticalStretch(0)
    @sizePolicy.heightForWidth = @groupBox.sizePolicy.hasHeightForWidth
    @groupBox.sizePolicy = @sizePolicy
    @groupBox.alignment = Qt::AlignHCenter|Qt::AlignTop
    @groupBox.flat = false
    @verticalLayout_2 = Qt::VBoxLayout.new(@groupBox)
    @verticalLayout_2.objectName = "verticalLayout_2"
    @viewActions = Qt::StackedWidget.new(@groupBox)
    @viewActions.objectName = "viewActions"
    @sizePolicy1 = Qt::SizePolicy.new(Qt::SizePolicy::Preferred, Qt::SizePolicy::Maximum)
    @sizePolicy1.setHorizontalStretch(0)
    @sizePolicy1.setVerticalStretch(0)
    @sizePolicy1.heightForWidth = @viewActions.sizePolicy.hasHeightForWidth
    @viewActions.sizePolicy = @sizePolicy1

    @verticalLayout_2.addWidget(@viewActions)

    @horizontalLayout = Qt::HBoxLayout.new()
    @horizontalLayout.objectName = "horizontalLayout"
    @horizontalLayout.setContentsMargins(-1, 0, -1, -1)
    @backToLibraries = Qt::PushButton.new(@groupBox)
    @backToLibraries.objectName = "backToLibraries"
    @sizePolicy2 = Qt::SizePolicy.new(Qt::SizePolicy::Fixed, Qt::SizePolicy::Fixed)
    @sizePolicy2.setHorizontalStretch(0)
    @sizePolicy2.setVerticalStretch(0)
    @sizePolicy2.heightForWidth = @backToLibraries.sizePolicy.hasHeightForWidth
    @backToLibraries.sizePolicy = @sizePolicy2
    @backToLibraries.minimumSize = Qt::Size.new(80, 80)
    @backToLibraries.styleSheet = "QPushButton {\n" \
"color: #ffffff;\n" \
"font-weight: bold;\n" \
"font-size: 14px;\n" \
"	border-image: url(:/120x120/images/buttons/round/120x120/Green.png);\n" \
"}\n" \
"QPushButton:pressed {\n" \
"	border-image: url(:/120x120/images/buttons/round/120x120/Red.png);\n" \
"}\n" \
"QPushButton:disabled {\n" \
"	border-image: url(:/120x120/images/buttons/round/120x120/Gray.png);\n" \
"}"
    @backToLibraries.iconSize = Qt::Size.new(0, 0)
    @backToLibraries.flat = true

    @horizontalLayout.addWidget(@backToLibraries)


    @verticalLayout_2.addLayout(@horizontalLayout)

    @verticalSpacer = Qt::SpacerItem.new(20, 40, Qt::SizePolicy::Minimum, Qt::SizePolicy::Expanding)

    @verticalLayout_2.addItem(@verticalSpacer)


    @gridLayout_2.addWidget(@groupBox, 0, 0, 1, 1)

    @viewLibrary = Qt::TabWidget.new(libraryWindow)
    @viewLibrary.objectName = "viewLibrary"
    @sizePolicy3 = Qt::SizePolicy.new(Qt::SizePolicy::Preferred, Qt::SizePolicy::Preferred)
    @sizePolicy3.setHorizontalStretch(0)
    @sizePolicy3.setVerticalStretch(0)
    @sizePolicy3.heightForWidth = @viewLibrary.sizePolicy.hasHeightForWidth
    @viewLibrary.sizePolicy = @sizePolicy3
    @viewLibrary.tabPosition = Qt::TabWidget::North
    @viewLibrary.elideMode = Qt::ElideMiddle
    @viewLibrary.usesScrollButtons = false
    @viewLibrary.documentMode = false
    @viewLibrary.tabsClosable = false
    @viewLibrary.movable = false
    @tabPreferences = Qt::Widget.new()
    @tabPreferences.objectName = "tabPreferences"
    @gridLayout_3 = Qt::GridLayout.new(@tabPreferences)
    @gridLayout_3.margin = 0
    @gridLayout_3.objectName = "gridLayout_3"
    @viewPreferences = Qt::StackedWidget.new(@tabPreferences)
    @viewPreferences.objectName = "viewPreferences"
    @sizePolicy3.heightForWidth = @viewPreferences.sizePolicy.hasHeightForWidth
    @viewPreferences.sizePolicy = @sizePolicy3

    @gridLayout_3.addWidget(@viewPreferences, 0, 0, 1, 1)

    @viewLibrary.addTab(@tabPreferences, Qt::Application.translate("LibraryWindow", "Preferences", nil, Qt::Application::UnicodeUTF8))
    @tabPreview = Qt::Widget.new()
    @tabPreview.objectName = "tabPreview"
    @gridLayout = Qt::GridLayout.new(@tabPreview)
    @gridLayout.objectName = "gridLayout"
    @viewPreview = Qt::StackedWidget.new(@tabPreview)
    @viewPreview.objectName = "viewPreview"

    @gridLayout.addWidget(@viewPreview, 0, 0, 1, 1)

    @viewLibrary.addTab(@tabPreview, Qt::Application.translate("LibraryWindow", "Preview", nil, Qt::Application::UnicodeUTF8))

    @gridLayout_2.addWidget(@viewLibrary, 0, 1, 1, 1)


    retranslateUi(libraryWindow)

    @viewLibrary.setCurrentIndex(0)


    Qt::MetaObject.connectSlotsByName(libraryWindow)
    end # setupUi

    def setup_ui(libraryWindow)
        setupUi(libraryWindow)
    end

    def retranslateUi(libraryWindow)
    libraryWindow.windowTitle = Qt::Application.translate("LibraryWindow", "Library", nil, Qt::Application::UnicodeUTF8)
    @groupBox.title = Qt::Application.translate("LibraryWindow", "Actions", nil, Qt::Application::UnicodeUTF8)
    @backToLibraries.text = Qt::Application.translate("LibraryWindow", "Back", nil, Qt::Application::UnicodeUTF8)
    @viewLibrary.setTabText(@viewLibrary.indexOf(@tabPreferences), Qt::Application.translate("LibraryWindow", "Preferences", nil, Qt::Application::UnicodeUTF8))
    @viewLibrary.setTabToolTip(@viewLibrary.indexOf(@tabPreferences), Qt::Application.translate("LibraryWindow", "Specify how you'd like your music to be organized", nil, Qt::Application::UnicodeUTF8))
    @viewLibrary.setTabText(@viewLibrary.indexOf(@tabPreview), Qt::Application.translate("LibraryWindow", "Preview", nil, Qt::Application::UnicodeUTF8))
    @viewLibrary.setTabToolTip(@viewLibrary.indexOf(@tabPreview), Qt::Application.translate("LibraryWindow", "Take a look at how your library will look like after organizing without actually doing it", nil, Qt::Application::UnicodeUTF8))
    end # retranslateUi

    def retranslate_ui(libraryWindow)
        retranslateUi(libraryWindow)
    end

end

module Ui
    class LibraryWindow < Ui_LibraryWindow
    end
end  # module Ui

