# PowerShell script to generate Production-Ready Agile Project Workbook for Epic Sports
# strictly following Career Shaper / ABABE Guidelines

$ErrorActionPreference = "Stop"

$outputPath = "d:\project\Epic_Sports_Agile_Project_Workbook.xlsx"
if (Test-Path $outputPath) {
    Remove-Item $outputPath -Force
}

$excel = New-Object -ComObject Excel.Application
$excel.Visible = $false
$excel.DisplayAlerts = $false

try {
    $wb = $excel.Workbooks.Add()
    
    # 13 Required Sheets
    $sheetNames = @(
        "Project Information",
        "Product Backlog",
        "Estimation",
        "Product Burndown",
        "Resource Plan",
        "IT Services Plan",
        "Training Plan",
        "Risk Management",
        "Opportunity Management",
        "Defects-Comments Data",
        "Impediments Log",
        "Action Items",
        "Story Clarity Index"
    )

    while ($wb.Worksheets.Count -lt $sheetNames.Count) {
        $wb.Worksheets.Add([System.Reflection.Missing]::Value, $wb.Worksheets.Item($wb.Worksheets.Count)) | Out-Null
    }
    while ($wb.Worksheets.Count -gt $sheetNames.Count) {
        $wb.Worksheets.Item($wb.Worksheets.Count).Delete()
    }

    for ($i = 0; $i -lt $sheetNames.Count; $i++) {
        $wb.Worksheets.Item($i + 1).Name = $sheetNames[$i]
    }

    # Formatting helper functions
    function Format-Header($range, $text, $bgColor = 0x5D361B, $fontColor = 0xFFFFFF) {
        $range.Value2 = [string]$text
        $range.Font.Bold = $true
        $range.Font.Color = $fontColor
        $range.Font.Name = "Segoe UI"
        $range.Font.Size = 10.5
        $range.Interior.Color = $bgColor
        $range.HorizontalAlignment = -4108 # xlCenter
        $range.VerticalAlignment = -4108
        $range.Borders.Weight = 2
        $range.Borders.Color = 0x888888
    }

    function Apply-TableBorders($range) {
        $range.Borders.Weight = 2 # xlThin
        $range.Borders.Color = 0xD0D7DE
    }

    # ==========================================
    # 1. SHEET: Project Information
    # ==========================================
    $ws = $wb.Worksheets.Item("Project Information")
    $ws.Tab.Color = 0x804000 # Navy

    # Title
    $ws.Range("B2:H2").Merge()
    $ws.Range("B2").Value2 = "EPIC SPORTS E-COMMERCE PLATFORM - AGILE PROJECT WORKBOOK"
    $ws.Range("B2").Font.Bold = $true
    $ws.Range("B2").Font.Size = 15
    $ws.Range("B2").Font.Color = 0xFFFFFF
    $ws.Range("B2").Font.Name = "Segoe UI"
    $ws.Range("B2").Interior.Color = 0x5D361B
    $ws.Range("B2").HorizontalAlignment = -4108
    $ws.Range("B2").RowHeight = 35

    $ws.Range("B3:H3").Merge()
    $ws.Range("B3").Value2 = "Note: Date format: dd-MMM-yy | Colored cells are auto-calculated (protected); only unshaded/white cells accept user inputs."
    $ws.Range("B3").Font.Italic = $true
    $ws.Range("B3").Font.Size = 9
    $ws.Range("B3").Font.Color = 0x555555
    $ws.Range("B3").HorizontalAlignment = -4108

    # Project Information Log Table
    $ws.Range("B5:H5").Merge()
    Format-Header $ws.Range("B5") "Project Information Log" 0x8C4C20

    $projectInfo = @(
        @("Project Name", "Epic Sports E-Commerce Web & Mobile Platform", "Start Date", "01-Nov-26"),
        @("Project Code", "ESP-AGL-2026-045", "Target Release Date", "15-Feb-27"),
        @("Scrum Master", "Ananya Roy", "Current Sprint", "Sprint 2 (Active)"),
        @("Product Owner", "David Miller (VP Retail & Digital)", "Release Number", "Release 1 (Core Storefront)"),
        @("Technical Lead", "Vikram Prajapati", "Methodology", "Scrum / Agile Framework"),
        @("Client / Sponsor", "Epic Sports Inc. USA", "Workbook Version", "1.2 (Production Ready)")
    )

    for ($r = 0; $r -lt $projectInfo.Count; $r++) {
        $row = 6 + $r
        $ws.Range("B$row").Value2 = [string]$projectInfo[$r][0]
        $ws.Range("B$row").Font.Bold = $true
        $ws.Range("B$row").Interior.Color = 0xF2F2F2
        $ws.Range("C$row:D$row").Merge()
        $ws.Range("C$row").Value2 = [string]$projectInfo[$r][1]
        
        $ws.Range("E$row").Value2 = [string]$projectInfo[$r][2]
        $ws.Range("E$row").Font.Bold = $true
        $ws.Range("E$row").Interior.Color = 0xF2F2F2
        $ws.Range("F$row:H$row").Merge()
        $ws.Range("F$row").Value2 = [string]$projectInfo[$r][3]
        if ($projectInfo[$r][2] -like "*Date*") {
            $ws.Range("F$row").NumberFormat = "dd-mmm-yy"
        }
    }
    Apply-TableBorders $ws.Range("B6:H11")

    # High-Level User Story Status (Auto-calculated)
    $ws.Range("B13:H13").Merge()
    Format-Header $ws.Range("B13") "High-Level Status of User Stories (Auto-Calculated Metrics)" 0x4A6B82

    $metricHeaders = @("Total Stories", "Completed", "In Progress", "Ready / Planned", "Total Story Points", "Completed Points")
    $metricCols = @("B", "C", "D", "E", "F", "G")
    for ($c = 0; $c -lt $metricHeaders.Count; $c++) {
        $col = $metricCols[$c]
        $ws.Range("${col}14").Value2 = [string]$metricHeaders[$c]
        $ws.Range("${col}14").Font.Bold = $true
        $ws.Range("${col}14").Interior.Color = 0xE6EDF2
        $ws.Range("${col}14").HorizontalAlignment = -4108
    }

    $ws.Range("B15").Formula = "=COUNTA('Product Backlog'!A4:A18)"
    $ws.Range("C15").Formula = "=COUNTIF('Product Backlog'!H4:H18, ""Completed"")"
    $ws.Range("D15").Formula = "=COUNTIF('Product Backlog'!H4:H18, ""In Progress"")"
    $ws.Range("E15").Formula = "=COUNTIF('Product Backlog'!H4:H18, ""Ready"") + COUNTIF('Product Backlog'!H4:H18, ""Planned"")"
    $ws.Range("F15").Formula = "=SUM(Estimation!E4:E18)"
    $ws.Range("G15").Formula = "=SUMIF('Product Backlog'!H4:H18, ""Completed"", Estimation!E4:E18)"

    $ws.Range("B15:G15").Interior.Color = 0xD9E2E8
    $ws.Range("B15:G15").Font.Bold = $true
    $ws.Range("B15:G15").Font.Size = 12
    $ws.Range("B15:G15").HorizontalAlignment = -4108
    Apply-TableBorders $ws.Range("B14:G15")

    # Workbook Contents Table
    $ws.Range("B17:H17").Merge()
    Format-Header $ws.Range("B17") "Contents of this Workbook" 0x8C4C20

    $tocData = @(
        @("Project Information", "Basic project information, team details, high-level metrics, and revision history"),
        @("Product Backlog", "Master list of User Stories with Epics, Acceptance Criteria, Priority, and Status"),
        @("Estimation", "Dev/QA effort breakdown, Story Points (Fibonacci), and complexity rationale"),
        @("Product Burndown", "Ideal vs. Actual points burndown across releases and sprints with graph"),
        @("Resource Plan", "Team member roles, responsibilities, planned vs actual loading hours and chart"),
        @("IT Services Plan", "Infrastructure, environments, cloud hosting, CI/CD, and IT tracking"),
        @("Training Plan", "Training requirements, methodology, schedule, and team skill tracking"),
        @("Risk Management", "Identified risks, normalized impact, cost of risk, mitigation plan, CBR & escalation"),
        @("Opportunity Management", "Identified opportunities, cost/benefit, opportunity value, priority & strategies"),
        @("Defects-Comments Data", "Verification data capturing review comments and testing defects by work product"),
        @("Impediments Log", "Operational and sprint impediments, impact, resolution plan, and status"),
        @("Action Items", "Sprint meeting action items, owners, target completion dates, and progress"),
        @("Story Clarity Index", "Calculator to compute clarity percentage and sprint readiness for user stories")
    )

    $ws.Range("B18").Value2 = "Sheet Name"
    $ws.Range("B18").Font.Bold = $true
    $ws.Range("B18").Interior.Color = 0xF2F2F2
    $ws.Range("C18:H18").Merge()
    $ws.Range("C18").Value2 = "Purpose & Contents"
    $ws.Range("C18").Font.Bold = $true
    $ws.Range("C18").Interior.Color = 0xF2F2F2

    for ($i = 0; $i -lt $tocData.Count; $i++) {
        $row = 19 + $i
        $ws.Range("B$row").Value2 = [string]$tocData[$i][0]
        $ws.Range("B$row").Font.Bold = $true
        $ws.Range("C$row:H$row").Merge()
        $ws.Range("C$row").Value2 = [string]$tocData[$i][1]
    }
    Apply-TableBorders $ws.Range("B18:H31")

    # Revision History
    $revRow = 19 + $tocData.Count + 1
    $ws.Range("B$revRow:H$revRow").Merge()
    Format-Header $ws.Range("B$revRow") "Revision History of this Workbook" 0x8C4C20

    $ws.Range("B$($revRow+1)").Value2 = "Rev #"
    $ws.Range("C$($revRow+1)").Value2 = "Date"
    $ws.Range("D$($revRow+1)").Value2 = "Author"
    $ws.Range("E$($revRow+1)").Value2 = "Reviewed By"
    $ws.Range("F$($revRow+1):H$($revRow+1)").Merge()
    $ws.Range("F$($revRow+1)").Value2 = "Description of Change"
    $ws.Range("B$($revRow+1):H$($revRow+1)").Font.Bold = $true
    $ws.Range("B$($revRow+1):H$($revRow+1)").Interior.Color = 0xF2F2F2

    $revisions = @(
        @("1.0", "01-Nov-26", "Ananya Roy", "David Miller", "Initial baseline creation of Agile Project Workbook and Product Backlog"),
        @("1.1", "08-Nov-26", "Vikram Prajapati", "Rajesh Sharma", "Updated estimation effort breakdown, IT services plan, and training matrix"),
        @("1.2", "15-Nov-26", "Ananya Roy", "David Miller", "Sprint 1 closure, Sprint 2 burndown update, risk escalation threshold review")
    )

    for ($i = 0; $i -lt $revisions.Count; $i++) {
        $r = $revRow + 2 + $i
        $ws.Range("B$r").Value2 = [string]$revisions[$i][0]
        $ws.Range("C$r").Value2 = [string]$revisions[$i][1]
        $ws.Range("C$r").NumberFormat = "dd-mmm-yy"
        $ws.Range("D$r").Value2 = [string]$revisions[$i][2]
        $ws.Range("E$r").Value2 = [string]$revisions[$i][3]
        $ws.Range("F$r:H$r").Merge()
        $ws.Range("F$r").Value2 = [string]$revisions[$i][4]
    }
    Apply-TableBorders $ws.Range("B$($revRow+1):H$($revRow+4)")

    $ws.Columns.Item(2).ColumnWidth = 24
    $ws.Columns.Item(3).ColumnWidth = 16
    $ws.Columns.Item(4).ColumnWidth = 20
    $ws.Columns.Item(5).ColumnWidth = 18
    $ws.Columns.Item(6).ColumnWidth = 20
    $ws.Columns.Item(7).ColumnWidth = 18
    $ws.Columns.Item(8).ColumnWidth = 24


    # ==========================================
    # 2. SHEET: Product Backlog
    # ==========================================
    $ws = $wb.Worksheets.Item("Product Backlog")
    $ws.Tab.Color = 0x207030 # Green

    $ws.Range("A1:H1").Merge()
    $ws.Range("A1").Value2 = "PRODUCT BACKLOG - EPIC SPORTS E-COMMERCE PLATFORM"
    $ws.Range("A1").Font.Bold = $true
    $ws.Range("A1").Font.Size = 14
    $ws.Range("A1").Font.Color = 0xFFFFFF
    $ws.Range("A1").Interior.Color = 0x207030
    $ws.Range("A1").HorizontalAlignment = -4108
    $ws.Range("A1").RowHeight = 30

    $ws.Range("A2:H2").Merge()
    $ws.Range("A2").Value2 = "Rule: Add Story # to this sheet first. It automatically replicates to Estimation and other pages. Do NOT leave blank rows."
    $ws.Range("A2").Font.Italic = $true
    $ws.Range("A2").Font.Size = 9
    $ws.Range("A2").Font.Color = 0x555555

    $backlogHeaders = @("Story #", "Epic / Module", "User Story Title", "User Story Description (As a / I want / So that)", "Acceptance Criteria", "Priority", "Target Release", "Status")
    for ($c = 0; $c -lt $backlogHeaders.Count; $c++) {
        $colLetter = [char](65 + $c)
        Format-Header $ws.Range("${colLetter}3") $backlogHeaders[$c] 0x2E7D32
    }

    $stories = @(
        @("US-001", "User Authentication", "Customer Registration & Social Login", "As a sports shopper, I want to sign up using email or Google/Apple ID, so that I can quickly access my saved profile and orders.", "Given valid credentials, When submitted, Then account is created with verification email and instant session token.", "Must Have", "Release 1 - Sprint 1", "Completed"),
        @("US-002", "Product Catalog", "Multi-Category Athletic Gear Catalog", "As a customer, I want to browse products categorized by sport (Soccer, Basketball, Running), so that I can easily discover relevant gear.", "Given category selection, When clicked, Then paginated product grid renders with price, rating, and stock badges.", "Must Have", "Release 1 - Sprint 1", "Completed"),
        @("US-003", "Product Search", "Dynamic Search with Auto-Complete", "As a shopper, I want real-time search suggestions with sports brand filtering, so that I find specific products in seconds.", "Given >=3 characters typed, When debounced 300ms, Then top 5 items and matching sports categories display in dropdown.", "Must Have", "Release 1 - Sprint 1", "Completed"),
        @("US-004", "Product Detail", "Interactive Product Details & Size Guide", "As an athlete, I want high-res zoomable images, size charts, and gear specifications, so that I select the correct fit.", "Given a product page, When size button is clicked, Then availability updates dynamically with visual size guide modal.", "Must Have", "Release 1 - Sprint 1", "Completed"),
        @("US-005", "Shopping Cart", "Real-Time Cart & Stock Reservation", "As a shopper, I want to add items to cart with temporary 15-minute stock hold, so that items aren't sold out while I shop.", "Given stock available, When added to cart, Then mini-cart updates item count, subtotal, and tax estimation in real time.", "Must Have", "Release 1 - Sprint 1", "Completed"),
        @("US-006", "Checkout", "Multi-Step Checkout with Address Validation", "As a buyer, I want a frictionless 3-step checkout with address autocompletion, so that I can complete orders quickly.", "Given valid shipping address, When verified via USPS/Google API, Then shipping options and total costs calculate accurately.", "Must Have", "Release 1 - Sprint 2", "In Progress"),
        @("US-007", "Payment Gateway", "Stripe, PayPal & Apple Pay Integration", "As a customer, I want to pay securely via credit card, PayPal, or digital wallet, so that my transaction is safe and PCI-compliant.", "Given 3D secure payment token, When processed, Then payment confirms within 3 seconds and returns gateway transaction ID.", "Must Have", "Release 1 - Sprint 2", "In Progress"),
        @("US-008", "Notifications", "Automated Order Confirmation & PDF Invoice", "As a customer, I want an immediate email/SMS confirmation with PDF receipt, so that I have proof of purchase and order summary.", "Given successful payment webhook, When triggered, Then formatted confirmation email with PDF attachment sends in <15s.", "Must Have", "Release 1 - Sprint 2", "In Progress"),
        @("US-009", "Order Tracking", "Customer Order History & Live GPS Tracking", "As a customer, I want to track my order shipment status via courier tracking API, so that I know exactly when it arrives.", "Given order ID and phone/email, When queried, Then visual milestone progress bar (Packed, Shipped, Out for Delivery) renders.", "Should Have", "Release 1 - Sprint 2", "Ready"),
        @("US-010", "Customization", "Team Uniform & Jersey Customizer", "As a sports team coach, I want to customize jerseys with player names, numbers, and team logos, so that we can order bulk uniforms.", "Given jersey template, When name/number typed, Then live 3D preview displays typography and calculates team discount tier.", "Should Have", "Release 1 - Sprint 2", "Ready"),
        @("US-011", "Inventory Sync", "Warehouse ERP Real-Time Stock Sync", "As an inventory manager, I want automated stock sync with warehouse ERP, so that out-of-stock items are disabled immediately.", "Given stock change in ERP, When webhook received, Then storefront inventory reflects delta across all regional distribution hubs.", "Must Have", "Release 1 - Sprint 3", "Planned"),
        @("US-012", "Discounts & Promos", "Promo Engine & Bulk Tier Discounts", "As a marketing manager, I want to create coupon codes and tiered discounts, so that we incentivize high-volume school/club orders.", "Given valid promo code, When applied at checkout, Then cart total discounts according to percentage or fixed thresholds.", "Should Have", "Release 1 - Sprint 3", "Planned"),
        @("US-013", "Social & Reviews", "Customer Reviews, Photo Uploads & Q&A", "As a prospective buyer, I want to read verified customer reviews and see user photos, so that I can evaluate gear durability.", "Given verified purchase, When review submitted with photos, Then it appears after automated spam filter verification.", "Could Have", "Release 1 - Sprint 3", "Planned"),
        @("US-014", "Returns / RMA", "Self-Service Returns & RMA Portal", "As a customer, I want to initiate hassle-free returns and generate prepaid shipping labels, so that return experience is smooth.", "Given order within 30-day window, When return requested, Then return barcode label is generated with refund tracking.", "Should Have", "Release 1 - Sprint 3", "Planned"),
        @("US-015", "Admin Analytics", "Executive Operations & Sales Dashboard", "As a business executive, I want real-time KPI graphs for daily GMV, conversion rate, and inventory turn, so that I make informed decisions.", "Given admin credentials, When dashboard loads, Then charts display revenue, top-selling sporting categories, and return rates.", "Must Have", "Release 1 - Sprint 3", "Planned")
    )

    for ($i = 0; $i -lt $stories.Count; $i++) {
        $row = 4 + $i
        for ($c = 0; $c -lt $stories[$i].Count; $c++) {
            $colLetter = [char](65 + $c)
            $ws.Range("${colLetter}$row").Value2 = [string]$stories[$i][$c]
            $ws.Range("${colLetter}$row").VerticalAlignment = -4108
        }
        $statusCell = $ws.Range("H$row")
        switch ($stories[$i][7]) {
            "Completed"   { $statusCell.Interior.Color = 0xC8E6C9; $statusCell.Font.Color = 0x1B5E20; $statusCell.Font.Bold = $true }
            "In Progress" { $statusCell.Interior.Color = 0xFFECB3; $statusCell.Font.Color = 0xE65100; $statusCell.Font.Bold = $true }
            "Ready"       { $statusCell.Interior.Color = 0xE1BEE7; $statusCell.Font.Color = 0x4A148C; $statusCell.Font.Bold = $true }
            "Planned"     { $statusCell.Interior.Color = 0xCFD8DC; $statusCell.Font.Color = 0x263238; $statusCell.Font.Bold = $true }
        }
    }
    Apply-TableBorders $ws.Range("A3:H18")

    # Data Validations on Backlog
    try {
        $priorityRange = $ws.Range("F4:F18")
        $priorityRange.Validation.Delete()
        $priorityRange.Validation.Add(3, 1, 1, "Must Have,Should Have,Could Have,Won't Have") # xlValidateList

        $statusRange = $ws.Range("H4:H18")
        $statusRange.Validation.Delete()
        $statusRange.Validation.Add(3, 1, 1, "Completed,In Progress,Ready,Planned")
    } catch { }

    $ws.Columns.Item(1).ColumnWidth = 12
    $ws.Columns.Item(2).ColumnWidth = 20
    $ws.Columns.Item(3).ColumnWidth = 32
    $ws.Columns.Item(4).ColumnWidth = 45
    $ws.Columns.Item(5).ColumnWidth = 45
    $ws.Columns.Item(6).ColumnWidth = 14
    $ws.Columns.Item(7).ColumnWidth = 22
    $ws.Columns.Item(8).ColumnWidth = 16


    # ==========================================
    # 3. SHEET: Estimation
    # ==========================================
    $ws = $wb.Worksheets.Item("Estimation")
    $ws.Tab.Color = 0x9C27B0 # Purple

    $ws.Range("A1:H1").Merge()
    $ws.Range("A1").Value2 = "ESTIMATION SHEET - USER STORY EFFORT & COMPLEXITY POINTS"
    $ws.Range("A1").Font.Bold = $true
    $ws.Range("A1").Font.Size = 14
    $ws.Range("A1").Font.Color = 0xFFFFFF
    $ws.Range("A1").Interior.Color = 0x6A1B9A
    $ws.Range("A1").HorizontalAlignment = -4108
    $ws.Range("A1").RowHeight = 30

    $ws.Range("A2:H2").Merge()
    $ws.Range("A2").Value2 = "Guideline: Story # and Title are formula-linked to Product Backlog. Story points use Fibonacci scale (1, 2, 3, 5, 8, 13)."
    $ws.Range("A2").Font.Italic = $true
    $ws.Range("A2").Font.Size = 9
    $ws.Range("A2").Font.Color = 0x555555

    $estHeaders = @("Story #", "User Story Title", "Dev Effort (Hrs)", "QA Effort (Hrs)", "Story Points", "Estimation Technique", "Assigned Team", "Complexity Rationale")
    for ($c = 0; $c -lt $estHeaders.Count; $c++) {
        $colLetter = [char](65 + $c)
        Format-Header $ws.Range("${colLetter}3") $estHeaders[$c] 0x6A1B9A
    }

    $estDetails = @(
        @(24, 12, 5, "Planning Poker", "Vikram P. / Priya N.", "OAuth2 / JWT implementation, email verification service"),
        @(32, 16, 8, "Planning Poker", "Sneha K. / Priya N.", "Multi-sport faceted search index, mobile-responsive grid"),
        @(28, 14, 5, "Planning Poker", "Amit V. / Priya N.", "Elasticsearch debounced auto-complete, high speed query"),
        @(24, 12, 5, "Planning Poker", "Sneha K. / Amit V.", "High-res media viewer, size conversion charts, dynamic stock check"),
        @(30, 16, 5, "Planning Poker", "Vikram P. / Priya N.", "Redis-based cart session holding, cart abandonment tracking"),
        @(40, 20, 8, "Planning Poker", "Amit V. / Sneha K.", "Address validation microservice integration, guest checkout"),
        @(48, 24, 13, "Planning Poker", "Vikram P. / Priya N.", "PCI-DSS compliance, 3D Secure, Stripe/PayPal webhooks"),
        @(18, 10, 3, "Planning Poker", "Amit V. / Priya N.", "SendGrid API integration, dynamic PDF rendering engine"),
        @(32, 16, 8, "Planning Poker", "Sneha K. / Amit V.", "Carrier tracking API integration (FedEx/UPS), timeline UI"),
        @(56, 28, 13, "Planning Poker", "Vikram P. / Sneha K.", "Canvas/WebGL 3D jersey customizer, typography engine, bulk calculation"),
        @(44, 22, 8, "Planning Poker", "Amit V. / Rohan M.", "Kafka/RabbitMQ message queue integration with warehouse ERP"),
        @(24, 12, 5, "Planning Poker", "Sneha K. / Amit V.", "Promotional rules engine, tiered coupon discount logic"),
        @(20, 10, 3, "Planning Poker", "Sneha K. / Priya N.", "User review submission, image compression, anti-spam validation"),
        @(36, 18, 8, "Planning Poker", "Amit V. / Priya N.", "Prepaid label generation via ShipStation API, return workflow"),
        @(40, 20, 8, "Planning Poker", "Vikram P. / Rohan M.", "Real-time analytics aggregation, charting library, export to CSV/PDF")
    )

    for ($i = 0; $i -lt $estDetails.Count; $i++) {
        $row = 4 + $i
        $backlogRow = 4 + $i
        $ws.Range("A$row").Formula = "='Product Backlog'!A$backlogRow"
        $ws.Range("B$row").Formula = "='Product Backlog'!C$backlogRow"
        
        $ws.Range("C$row").Value2 = [double]$estDetails[$i][0]
        $ws.Range("D$row").Value2 = [double]$estDetails[$i][1]
        $ws.Range("E$row").Value2 = [double]$estDetails[$i][2]
        $ws.Range("F$row").Value2 = [string]$estDetails[$i][3]
        $ws.Range("G$row").Value2 = [string]$estDetails[$i][4]
        $ws.Range("H$row").Value2 = [string]$estDetails[$i][5]

        $ws.Range("A$row:B$row").Interior.Color = 0xF3E5F5
        $ws.Range("E$row").Font.Bold = $true
        $ws.Range("E$row").HorizontalAlignment = -4108
    }

    # Total Summary Row
    $sumRow = 4 + $estDetails.Count
    $ws.Range("A$sumRow").Value2 = "TOTAL"
    $ws.Range("A$sumRow:B$sumRow").Merge()
    $ws.Range("A$sumRow").Font.Bold = $true
    $ws.Range("A$sumRow").HorizontalAlignment = -4108
    $ws.Range("A$sumRow:H$sumRow").Interior.Color = 0xCE93D8
    $ws.Range("C$sumRow").Formula = "=SUM(C4:C$($sumRow-1))"
    $ws.Range("D$sumRow").Formula = "=SUM(D4:D$($sumRow-1))"
    $ws.Range("E$sumRow").Formula = "=SUM(E4:E$($sumRow-1))"
    $ws.Range("C$sumRow:E$sumRow").Font.Bold = $true
    $ws.Range("F$sumRow").Value2 = "Total Team Effort"
    $ws.Range("G$sumRow:H$sumRow").Merge()
    $ws.Range("G$sumRow").Formula = "=""Total Hours: "" & (C$sumRow + D$sumRow) & "" hrs ("" & E$sumRow & "" Story Points)"""
    $ws.Range("G$sumRow").Font.Bold = $true

    Apply-TableBorders $ws.Range("A3:H19")

    $ws.Columns.Item(1).ColumnWidth = 12
    $ws.Columns.Item(2).ColumnWidth = 35
    $ws.Columns.Item(3).ColumnWidth = 16
    $ws.Columns.Item(4).ColumnWidth = 16
    $ws.Columns.Item(5).ColumnWidth = 14
    $ws.Columns.Item(6).ColumnWidth = 22
    $ws.Columns.Item(7).ColumnWidth = 24
    $ws.Columns.Item(8).ColumnWidth = 45


    # ==========================================
    # 4. SHEET: Product Burndown
    # ==========================================
    $ws = $wb.Worksheets.Item("Product Burndown")
    $ws.Tab.Color = 0xE65100 # Orange

    $ws.Range("A1:H1").Merge()
    $ws.Range("A1").Value2 = "PRODUCT & RELEASE BURNDOWN - EPIC SPORTS"
    $ws.Range("A1").Font.Bold = $true
    $ws.Range("A1").Font.Size = 14
    $ws.Range("A1").Font.Color = 0xFFFFFF
    $ws.Range("A1").Interior.Color = 0xE65100
    $ws.Range("A1").HorizontalAlignment = -4108
    $ws.Range("A1").RowHeight = 30

    # Controls row
    $ws.Range("A3").Value2 = "Release Filter:"
    $ws.Range("A3").Font.Bold = $true
    $ws.Range("B3").Value2 = "Release 1 (All Sprints)"
    $ws.Range("B3").Interior.Color = 0xFFF3E0
    $ws.Range("B3").Font.Bold = $true
    $ws.Range("D3:E3").Merge()
    $ws.Range("D3").Value2 = "[Generate / Refresh Graph]"
    $ws.Range("D3").Font.Bold = $true
    $ws.Range("D3").Font.Color = 0xFFFFFF
    $ws.Range("D3").Interior.Color = 0xBF360C
    $ws.Range("D3").HorizontalAlignment = -4108

    $burnHeaders = @("Sprint / Day", "Date", "Sprint Goal", "Ideal Remaining Points", "Actual Remaining Points", "Points Completed", "Daily Velocity", "Notes / Remarks")
    for ($c = 0; $c -lt $burnHeaders.Count; $c++) {
        $colLetter = [char](65 + $c)
        Format-Header $ws.Range("${colLetter}5") $burnHeaders[$c] 0xEF6C00
    }

    $burnData = @(
        @("Sprint 1 - Day 1", "01-Nov-26", "Sprint 1: Auth, Catalog & Cart Baseline", 100, 100, 0, 0, "Sprint 1 kick-off, team onboarded"),
        @("Sprint 1 - Day 3", "03-Nov-26", "Sprint 1: Auth, Catalog & Cart Baseline", 93, 95, 5, 5, "US-001 Auth completed ahead of schedule"),
        @("Sprint 1 - Day 5", "05-Nov-26", "Sprint 1: Auth, Catalog & Cart Baseline", 86, 87, 8, 8, "US-002 Catalog filtering completed"),
        @("Sprint 1 - Day 8", "08-Nov-26", "Sprint 1: Auth, Catalog & Cart Baseline", 79, 82, 5, 5, "US-003 Search indexing verified"),
        @("Sprint 1 - Day 10", "10-Nov-26", "Sprint 1: Auth, Catalog & Cart Baseline", 72, 72, 10, 10, "US-004 & US-005 finished; Sprint 1 goal achieved (28 pts)"),
        @("Sprint 2 - Day 1", "11-Nov-26", "Sprint 2: Checkout, Payments & Customizer", 72, 72, 0, 0, "Sprint 2 kick-off; 34 pts planned"),
        @("Sprint 2 - Day 3", "13-Nov-26", "Sprint 2: Checkout, Payments & Customizer", 65, 68, 4, 4, "US-006 address validation microservice connected"),
        @("Sprint 2 - Day 5", "15-Nov-26", "Sprint 2: Checkout, Payments & Customizer", 58, 62, 6, 6, "Payment gateway webhook sandbox configured (Current Day)"),
        @("Sprint 2 - Day 8 (Est)", "18-Nov-26", "Sprint 2: Checkout, Payments & Customizer", 51, 51, 11, 11, "Targeting US-007 Stripe/PayPal completion"),
        @("Sprint 2 - Day 10 (Est)", "20-Nov-26", "Sprint 2: Checkout, Payments & Customizer", 44, 44, 7, 7, "Sprint 2 target completion (38 remaining)"),
        @("Sprint 3 - Day 1 (Est)", "21-Nov-26", "Sprint 3: ERP Sync, Reviews & Admin", 44, 44, 0, 0, "Sprint 3 planning"),
        @("Sprint 3 - Day 5 (Est)", "25-Nov-26", "Sprint 3: ERP Sync, Reviews & Admin", 22, 22, 22, 22, "Mid-sprint ERP integration testing"),
        @("Sprint 3 - Day 10 (Est)", "30-Nov-26", "Sprint 3: Release 1 Final Sign-off", 0, 0, 22, 22, "Full Release 1 completed for production deployment")
    )

    for ($i = 0; $i -lt $burnData.Count; $i++) {
        $row = 6 + $i
        $ws.Range("A$row").Value2 = [string]$burnData[$i][0]
        $ws.Range("B$row").Value2 = [string]$burnData[$i][1]
        $ws.Range("B$row").NumberFormat = "dd-mmm-yy"
        $ws.Range("C$row").Value2 = [string]$burnData[$i][2]
        $ws.Range("D$row").Value2 = [double]$burnData[$i][3]
        $ws.Range("E$row").Value2 = [double]$burnData[$i][4]
        $ws.Range("F$row").Value2 = [double]$burnData[$i][5]
        $ws.Range("G$row").Value2 = [double]$burnData[$i][6]
        $ws.Range("H$row").Value2 = [string]$burnData[$i][7]

        $ws.Range("D$row:G$row").HorizontalAlignment = -4108
        $ws.Range("D$row").Interior.Color = 0xFFF3E0
        $ws.Range("E$row").Interior.Color = 0xFFE0B2
    }
    Apply-TableBorders $ws.Range("A5:H18")

    $ws.Columns.Item(1).ColumnWidth = 20
    $ws.Columns.Item(2).ColumnWidth = 14
    $ws.Columns.Item(3).ColumnWidth = 36
    $ws.Columns.Item(4).ColumnWidth = 22
    $ws.Columns.Item(5).ColumnWidth = 22
    $ws.Columns.Item(6).ColumnWidth = 18
    $ws.Columns.Item(7).ColumnWidth = 16
    $ws.Columns.Item(8).ColumnWidth = 42

    # Add Burndown Chart
    try {
        $chartObj = $ws.ChartObjects().Add(520, 100, 480, 280)
        $chart = $chartObj.Chart
        $chart.ChartType = 4 # xlLineMarkers
        $chartRange = $ws.Range("B5:B18,D5:E18")
        $chart.SetSourceData($chartRange)
        $chart.HasTitle = $true
        $chart.ChartTitle.Text = "Release 1 Burndown Chart (Ideal vs Actual Points)"
    } catch { }


    # ==========================================
    # 5. SHEET: Resource Plan (Staffing)
    # ==========================================
    $ws = $wb.Worksheets.Item("Resource Plan")
    $ws.Tab.Color = 0x00838F # Cyan

    $ws.Range("A1:J1").Merge()
    $ws.Range("A1").Value2 = "RESOURCE PLAN & STAFFING LOADING - EPIC SPORTS"
    $ws.Range("A1").Font.Bold = $true
    $ws.Range("A1").Font.Size = 14
    $ws.Range("A1").Font.Color = 0xFFFFFF
    $ws.Range("A1").Interior.Color = 0x00838F
    $ws.Range("A1").HorizontalAlignment = -4108
    $ws.Range("A1").RowHeight = 30

    $ws.Range("A2:J2").Merge()
    $ws.Range("A2").Value2 = "Guidelines: Staffing sheet captures role, responsibilities, contact info, planned vs. actual loading hours across weeks."
    $ws.Range("A2").Font.Italic = $true
    $ws.Range("A2").Font.Size = 9
    $ws.Range("A2").Font.Color = 0x555555

    $resHeaders = @("Member Name", "Project Role", "Key Responsibilities", "Email Address", "Location", "Phone / Ext", "W1 (Plan/Act)", "W2 (Plan/Act)", "W3 (Plan/Act)", "W4 (Plan/Act)")
    for ($c = 0; $c -lt $resHeaders.Count; $c++) {
        $colLetter = [char](65 + $c)
        Format-Header $ws.Range("${colLetter}3") $resHeaders[$c] 0x00838F
    }

    $team = @(
        @("Vikram Prajapati", "Lead Full Stack Architect", "Overall architecture, secure microservices, payment integration, tech reviews", "vikram.prajapati@epicsports.com", "Bangalore, IN", "+91-98765-43210", "40 / 42", "40 / 41", "40 / 39", "40 / 40"),
        @("Sneha Kulkarni", "Senior Frontend Engineer", "React/Next.js storefront, dynamic catalog UI, responsive design, state management", "sneha.kulkarni@epicsports.com", "Pune, IN", "+91-98765-43211", "40 / 40", "40 / 42", "40 / 40", "40 / 40"),
        @("Amit Verma", "Backend Developer", "Node.js REST/GraphQL APIs, database schema, ERP inventory sync, promo engine", "amit.verma@epicsports.com", "Noida, IN", "+91-98765-43212", "40 / 38", "40 / 40", "40 / 41", "40 / 40"),
        @("Priya Nair", "QA Automation Lead", "Cypress/Selenium test automation, API testing, regression suites, defect triage", "priya.nair@epicsports.com", "Chennai, IN", "+91-98765-43213", "40 / 40", "40 / 39", "40 / 42", "40 / 40"),
        @("Rohan Mehta", "DevOps & Cloud Engineer", "AWS ECS/EKS infrastructure, Terraform, CI/CD GitHub Actions, CloudWatch monitoring", "rohan.mehta@epicsports.com", "Hyderabad, IN", "+91-98765-43214", "40 / 42", "40 / 40", "40 / 40", "40 / 40"),
        @("Ananya Roy", "Scrum Master", "Agile ceremonies facilitation, impediments removal, burndown tracking, team velocity", "ananya.roy@epicsports.com", "Kolkata, IN", "+91-98765-43215", "40 / 40", "40 / 40", "40 / 40", "40 / 40"),
        @("David Miller", "Product Owner", "Product vision, backlog prioritization, user story acceptance criteria, business sign-off", "david.miller@epicsports.com", "Chicago, USA", "+1-312-555-0199", "20 / 22", "20 / 20", "20 / 21", "20 / 20")
    )

    for ($i = 0; $i -lt $team.Count; $i++) {
        $row = 4 + $i
        for ($c = 0; $c -lt $team[$i].Count; $c++) {
            $colLetter = [char](65 + $c)
            $ws.Range("${colLetter}$row").Value2 = [string]$team[$i][$c]
            $ws.Range("${colLetter}$row").VerticalAlignment = -4108
        }
        $ws.Range("A$row").Font.Bold = $true
        $ws.Range("G$row:J$row").HorizontalAlignment = -4108
        $ws.Range("G$row:J$row").Interior.Color = 0xE0F7FA
    }
    Apply-TableBorders $ws.Range("A3:J10")

    $ws.Columns.Item(1).ColumnWidth = 20
    $ws.Columns.Item(2).ColumnWidth = 24
    $ws.Columns.Item(3).ColumnWidth = 45
    $ws.Columns.Item(4).ColumnWidth = 30
    $ws.Columns.Item(5).ColumnWidth = 18
    $ws.Columns.Item(6).ColumnWidth = 18
    $ws.Columns.Item(7).ColumnWidth = 16
    $ws.Columns.Item(8).ColumnWidth = 16
    $ws.Columns.Item(9).ColumnWidth = 16
    $ws.Columns.Item(10).ColumnWidth = 16


    # ==========================================
    # 6. SHEET: IT Services Plan
    # ==========================================
    $ws = $wb.Worksheets.Item("IT Services Plan")
    $ws.Tab.Color = 0x37474F # Blue Grey

    $ws.Range("A1:H1").Merge()
    $ws.Range("A1").Value2 = "IT SERVICES & INFRASTRUCTURE PLAN - EPIC SPORTS"
    $ws.Range("A1").Font.Bold = $true
    $ws.Range("A1").Font.Size = 14
    $ws.Range("A1").Font.Color = 0xFFFFFF
    $ws.Range("A1").Interior.Color = 0x37474F
    $ws.Range("A1").HorizontalAlignment = -4108
    $ws.Range("A1").RowHeight = 30

    $itHeaders = @("Service #", "Service Category", "Requirement Description", "Target Specification / Tool", "Environment", "Target Date", "Responsible Owner", "Status")
    for ($c = 0; $c -lt $itHeaders.Count; $c++) {
        $colLetter = [char](65 + $c)
        Format-Header $ws.Range("${colLetter}3") $itHeaders[$c] 0x37474F
    }

    $itServices = @(
        @("IT-01", "Cloud Infrastructure", "Scalable container cluster for frontend and backend microservices", "AWS ECS Fargate (4 vCPU, 16GB RAM autoscaling)", "Dev, QA, Prod", "02-Nov-26", "Rohan Mehta", "Provisioned"),
        @("IT-02", "Database & Caching", "Managed relational DB with Redis high-throughput caching cluster", "AWS Aurora PostgreSQL 15 + AWS ElastiCache Redis", "Dev, QA, Prod", "03-Nov-26", "Amit Verma", "Provisioned"),
        @("IT-03", "CI/CD Automation", "Automated build, lint, test, and container deployment pipelines", "GitHub Actions Enterprise with Docker registry", "All Envs", "04-Nov-26", "Rohan Mehta", "Provisioned"),
        @("IT-04", "Security & Certificates", "SSL/TLS Wildcard certificates, Cloudflare WAF, and DDoS defense", "Cloudflare Business Tier + AWS ACM SSL", "Staging, Prod", "08-Nov-26", "Vikram Prajapati", "Configured"),
        @("IT-05", "Payment Integration Sandbox", "PCI-DSS certified developer sandbox for payment testing", "Stripe Connect + PayPal Sandbox developer accounts", "Dev, QA", "09-Nov-26", "Vikram Prajapati", "Configured"),
        @("IT-06", "ERP Integration Gateway", "Secure VPN tunnel linking AWS VPC to Epic Sports warehouse ERP", "AWS Site-to-Site IPsec VPN + API Gateway", "QA, Prod", "18-Nov-26", "Rohan Mehta", "In Progress"),
        @("IT-07", "Monitoring & Alerts", "Centralized APM logging, error tracking, and threshold paging", "Datadog + AWS CloudWatch + PagerDuty integration", "Prod", "22-Nov-26", "Rohan Mehta", "Planned")
    )

    for ($i = 0; $i -lt $itServices.Count; $i++) {
        $row = 4 + $i
        for ($c = 0; $c -lt $itServices[$i].Count; $c++) {
            $colLetter = [char](65 + $c)
            $ws.Range("${colLetter}$row").Value2 = [string]$itServices[$i][$c]
            $ws.Range("${colLetter}$row").VerticalAlignment = -4108
        }
        $ws.Range("F$row").NumberFormat = "dd-mmm-yy"
        $statusCell = $ws.Range("H$row")
        switch ($itServices[$i][7]) {
            "Provisioned" { $statusCell.Interior.Color = 0xC8E6C9; $statusCell.Font.Color = 0x1B5E20; $statusCell.Font.Bold = $true }
            "Configured"  { $statusCell.Interior.Color = 0xC8E6C9; $statusCell.Font.Color = 0x1B5E20; $statusCell.Font.Bold = $true }
            "In Progress" { $statusCell.Interior.Color = 0xFFECB3; $statusCell.Font.Color = 0xE65100; $statusCell.Font.Bold = $true }
            "Planned"     { $statusCell.Interior.Color = 0xCFD8DC; $statusCell.Font.Color = 0x263238; $statusCell.Font.Bold = $true }
        }
    }
    Apply-TableBorders $ws.Range("A3:H10")

    $ws.Columns.Item(1).ColumnWidth = 14
    $ws.Columns.Item(2).ColumnWidth = 24
    $ws.Columns.Item(3).ColumnWidth = 45
    $ws.Columns.Item(4).ColumnWidth = 35
    $ws.Columns.Item(5).ColumnWidth = 18
    $ws.Columns.Item(6).ColumnWidth = 14
    $ws.Columns.Item(7).ColumnWidth = 20
    $ws.Columns.Item(8).ColumnWidth = 16


    # ==========================================
    # 7. SHEET: Training Plan
    # ==========================================
    $ws = $wb.Worksheets.Item("Training Plan")
    $ws.Tab.Color = 0x1565C0 # Blue

    $ws.Range("A1:H1").Merge()
    $ws.Range("A1").Value2 = "PROJECT TRAINING PLAN - EPIC SPORTS"
    $ws.Range("A1").Font.Bold = $true
    $ws.Range("A1").Font.Size = 14
    $ws.Range("A1").Font.Color = 0xFFFFFF
    $ws.Range("A1").Interior.Color = 0x1565C0
    $ws.Range("A1").HorizontalAlignment = -4108
    $ws.Range("A1").RowHeight = 30

    $ws.Range("A2:H2").Merge()
    $ws.Range("A2").Value2 = "Guidelines: Captures training requirements, Type of training, Training methodology, and Status tracking."
    $ws.Range("A2").Font.Italic = $true
    $ws.Range("A2").Font.Size = 9
    $ws.Range("A2").Font.Color = 0x555555

    $trnHeaders = @("Training ID", "Training Requirement / Topic", "Target Audience", "Type of Training", "Training Methodology", "Completion Date", "Trainer / Platform", "Status")
    for ($c = 0; $c -lt $trnHeaders.Count; $c++) {
        $colLetter = [char](65 + $c)
        Format-Header $ws.Range("${colLetter}3") $trnHeaders[$c] 0x1565C0
    }

    $trainings = @(
        @("TRN-01", "PCI-DSS Compliance & Secure Payment Tokenization", "Backend Devs & QA Lead", "Technical / Security", "Instructor-Led Workshop", "04-Nov-26", "CyberSec External Consultant", "Completed"),
        @("TRN-02", "Next.js 14 App Router & SSR Performance", "Frontend Developers", "Technical", "E-Learning & Hands-on Lab", "06-Nov-26", "Vercel Enterprise Academy", "Completed"),
        @("TRN-03", "Agile Scrum Ceremonies & Story Estimation", "Entire Project Team", "Agile / Process", "Interactive Workshop", "02-Nov-26", "Ananya Roy (Scrum Master)", "Completed"),
        @("TRN-04", "Cypress End-to-End Test Automation Patterns", "QA & Developers", "Technical / QA", "Peer Mentoring & Code-along", "14-Nov-26", "Priya Nair (QA Lead)", "Completed"),
        @("TRN-05", "Warehouse ERP API Integration & Event Streaming", "Backend & DevOps Leads", "Domain / Technical", "Vendor-Led Training", "20-Nov-26", "Epic Sports ERP Vendor", "In Progress"),
        @("TRN-06", "Advanced AWS Cloud Security & Terraform CI/CD", "DevOps Engineer", "Technical / Cloud", "E-Learning Certification", "28-Nov-26", "AWS Skill Builder", "Planned")
    )

    for ($i = 0; $i -lt $trainings.Count; $i++) {
        $row = 4 + $i
        for ($c = 0; $c -lt $trainings[$i].Count; $c++) {
            $colLetter = [char](65 + $c)
            $ws.Range("${colLetter}$row").Value2 = [string]$trainings[$i][$c]
            $ws.Range("${colLetter}$row").VerticalAlignment = -4108
        }
        $ws.Range("F$row").NumberFormat = "dd-mmm-yy"
        $statusCell = $ws.Range("H$row")
        switch ($trainings[$i][7]) {
            "Completed"   { $statusCell.Interior.Color = 0xC8E6C9; $statusCell.Font.Color = 0x1B5E20; $statusCell.Font.Bold = $true }
            "In Progress" { $statusCell.Interior.Color = 0xFFECB3; $statusCell.Font.Color = 0xE65100; $statusCell.Font.Bold = $true }
            "Planned"     { $statusCell.Interior.Color = 0xCFD8DC; $statusCell.Font.Color = 0x263238; $statusCell.Font.Bold = $true }
        }
    }
    Apply-TableBorders $ws.Range("A3:H9")

    $ws.Columns.Item(1).ColumnWidth = 14
    $ws.Columns.Item(2).ColumnWidth = 36
    $ws.Columns.Item(3).ColumnWidth = 24
    $ws.Columns.Item(4).ColumnWidth = 22
    $ws.Columns.Item(5).ColumnWidth = 28
    $ws.Columns.Item(6).ColumnWidth = 16
    $ws.Columns.Item(7).ColumnWidth = 26
    $ws.Columns.Item(8).ColumnWidth = 16


    # ==========================================
    # 8. SHEET: Risk Management + Battle Map
    # ==========================================
    $ws = $wb.Worksheets.Item("Risk Management")
    $ws.Tab.Color = 0xC62828 # Red

    $ws.Range("A1:M1").Merge()
    $ws.Range("A1").Value2 = "RISK MANAGEMENT REGISTER & ESCALATION LOG - EPIC SPORTS"
    $ws.Range("A1").Font.Bold = $true
    $ws.Range("A1").Font.Size = 14
    $ws.Range("A1").Font.Color = 0xFFFFFF
    $ws.Range("A1").Interior.Color = 0xC62828
    $ws.Range("A1").HorizontalAlignment = -4108
    $ws.Range("A1").RowHeight = 30

    $ws.Range("A2:M2").Merge()
    $ws.Range("A2").Value2 = "Guidelines: Color coding: Shaded = Open risks; Tan (#D2B48C) = Past Escalation Threshold (Exposure>=15); Light Green = Closed. Update date in dd-MMM-yy."
    $ws.Range("A2").Font.Italic = $true
    $ws.Range("A2").Font.Size = 9
    $ws.Range("A2").Font.Color = 0x555555

    $riskHeaders = @("Risk ID", "Risk Title", "Risk Source", "Phase Identified", "Prob (1-5)", "Norm Impact (1-5)", "Risk Exposure", "Cost of Risk ($)", "Cost of Mitigation ($)", "Cost Benefit Ratio", "Update Date", "Status", "Escalation Action")
    for ($c = 0; $c -lt $riskHeaders.Count; $c++) {
        $colLetter = [char](65 + $c)
        Format-Header $ws.Range("${colLetter}3") $riskHeaders[$c] 0xC62828
    }

    $risks = @(
        @("RSK-01", "Third-Party Payment Gateway Sandbox Delays", "Vendor / Engineering", "Sprint 1", 4, 4, 18000, 3500, "15-Nov-26", "Open - Escalated", "Escalated to Sponsor; parallel Stripe + PayPal sandbox setup"),
        @("RSK-02", "Holiday Peak Load Concurrency Spike", "Infrastructure", "Sprint 1", 3, 3, 12000, 2500, "12-Nov-26", "Open", "AWS autoscaling policies & Redis caching applied"),
        @("RSK-03", "Custom Team Jersey 3D Canvas Rendering Overhead", "Engineering / UX", "Sprint 2", 4, 4, 20000, 4000, "15-Nov-26", "Open - Escalated", "Escalated to Tech Lead; WebGL hardware acceleration fallback"),
        @("RSK-04", "Warehouse ERP Real-time Inventory Feed Latency", "External Partner", "Sprint 2", 3, 4, 15000, 3000, "14-Nov-26", "Open", "Implemented async RabbitMQ message buffer with queue alerts"),
        @("RSK-05", "Non-Compliance with PCI-DSS Tokenization Standard", "Regulatory / Security", "Inception", 2, 5, 25000, 5000, "08-Nov-26", "Closed", "Achieved full tokenization via Stripe Elements; audited and signed off")
    )

    for ($i = 0; $i -lt $risks.Count; $i++) {
        $row = 4 + $i
        $ws.Range("A$row").Value2 = [string]$risks[$i][0]
        $ws.Range("B$row").Value2 = [string]$risks[$i][1]
        $ws.Range("C$row").Value2 = [string]$risks[$i][2]
        $ws.Range("D$row").Value2 = [string]$risks[$i][3]
        $ws.Range("E$row").Value2 = [double]$risks[$i][4] # Prob
        $ws.Range("F$row").Value2 = [double]$risks[$i][5] # Impact
        $ws.Range("G$row").Formula = "=E$row * F$row"     # Exposure
        $ws.Range("H$row").Value2 = [double]$risks[$i][6] # Cost Risk
        $ws.Range("I$row").Value2 = [double]$risks[$i][7] # Cost Mitigation
        $ws.Range("J$row").Formula = "=H$row / I$row"     # Cost Benefit Ratio
        $ws.Range("K$row").Value2 = [string]$risks[$i][8] # Date
        $ws.Range("K$row").NumberFormat = "dd-mmm-yy"
        $ws.Range("L$row").Value2 = [string]$risks[$i][9] # Status
        $ws.Range("M$row").Value2 = [string]$risks[$i][10] # Action

        $ws.Range("E$row:G$row").HorizontalAlignment = -4108
        $ws.Range("J$row").HorizontalAlignment = -4108
        $ws.Range("J$row").NumberFormat = "0.00"
        $ws.Range("H$row:I$row").NumberFormat = "$#,##0"

        # LMS Tan color coding for escalated risks past threshold
        if ($risks[$i][9] -like "*Escalated*") {
            $ws.Range("A$row:M$row").Interior.Color = 0x8CB4D2 # Tan (RGB: 210, 180, 140)
            $ws.Range("A$row:M$row").Font.Bold = $true
        } elseif ($risks[$i][9] -eq "Closed") {
            $ws.Range("A$row:M$row").Interior.Color = 0xC8E6C9 # Light Green
        } else {
            $ws.Range("A$row:M$row").Interior.Color = 0xE8F0FE # Shaded Open
        }
    }
    Apply-TableBorders $ws.Range("A3:M8")

    # Risk Management Battle Map Chart (5x5 Matrix) as mandated in Guideline 4!
    $ws.Range("B11:G11").Merge()
    Format-Header $ws.Range("B11") "Risk Battle Map (5x5 Probability vs. Impact Matrix)" 0x8C2020

    $ws.Range("B12").Value2 = "Prob \ Impact"
    $ws.Range("B12").Font.Bold = $true
    $ws.Range("B12").Interior.Color = 0xF2F2F2
    $ws.Range("C12").Value2 = "1 - Negligible"
    $ws.Range("D12").Value2 = "2 - Minor"
    $ws.Range("E12").Value2 = "3 - Moderate"
    $ws.Range("F12").Value2 = "4 - Major"
    $ws.Range("G12").Value2 = "5 - Critical"
    $ws.Range("C12:G12").Font.Bold = $true
    $ws.Range("C12:G12").HorizontalAlignment = -4108

    $matrixLabels = @(
        @("5 - Very High", "", "", "RSK-05 (Closed)", "", ""),
        @("4 - High",      "", "", "", "RSK-01, RSK-03 [TAN]", ""),
        @("3 - Medium",    "", "", "RSK-02", "RSK-04", ""),
        @("2 - Low",       "", "", "", "", ""),
        @("1 - Rare",      "", "", "", "", "")
    )

    for ($m = 0; $m -lt $matrixLabels.Count; $m++) {
        $mRow = 13 + $m
        $ws.Range("B$mRow").Value2 = [string]$matrixLabels[$m][0]
        $ws.Range("B$mRow").Font.Bold = $true
        $ws.Range("B$mRow").Interior.Color = 0xF2F2F2
        for ($col = 1; $col -le 5; $col++) {
            $colL = [char](66 + $col)
            $cell = $ws.Range("${colL}$mRow")
            $cell.Value2 = [string]$matrixLabels[$m][$col]
            $cell.HorizontalAlignment = -4108
            $cell.VerticalAlignment = -4108
            if ($matrixLabels[$m][$col] -like "*TAN*") {
                $cell.Interior.Color = 0x8CB4D2
                $cell.Font.Bold = $true
            } elseif ($matrixLabels[$m][$col] -like "*Closed*") {
                $cell.Interior.Color = 0xC8E6C9
            } elseif ($matrixLabels[$m][$col] -ne "") {
                $cell.Interior.Color = 0xE8F0FE
            }
        }
    }
    Apply-TableBorders $ws.Range("B12:G17")

    $ws.Columns.Item(1).ColumnWidth = 12
    $ws.Columns.Item(2).ColumnWidth = 35
    $ws.Columns.Item(3).ColumnWidth = 22
    $ws.Columns.Item(4).ColumnWidth = 16
    $ws.Columns.Item(5).ColumnWidth = 12
    $ws.Columns.Item(6).ColumnWidth = 16
    $ws.Columns.Item(7).ColumnWidth = 14
    $ws.Columns.Item(8).ColumnWidth = 16
    $ws.Columns.Item(9).ColumnWidth = 18
    $ws.Columns.Item(10).ColumnWidth = 16
    $ws.Columns.Item(11).ColumnWidth = 14
    $ws.Columns.Item(12).ColumnWidth = 18
    $ws.Columns.Item(13).ColumnWidth = 40


    # ==========================================
    # 9. SHEET: Opportunity Management
    # ==========================================
    $ws = $wb.Worksheets.Item("Opportunity Management")
    $ws.Tab.Color = 0xF57F17 # Amber

    $ws.Range("A1:K1").Merge()
    $ws.Range("A1").Value2 = "OPPORTUNITY MANAGEMENT REGISTER - EPIC SPORTS"
    $ws.Range("A1").Font.Bold = $true
    $ws.Range("A1").Font.Size = 14
    $ws.Range("A1").Font.Color = 0xFFFFFF
    $ws.Range("A1").Interior.Color = 0xF57F17
    $ws.Range("A1").HorizontalAlignment = -4108
    $ws.Range("A1").RowHeight = 30

    $ws.Range("A2:K2").Merge()
    $ws.Range("A2").Value2 = "Guidelines: Opportunity Value = Expected Benefits - Implementation Cost. Priority based on value (Hot Pursuit, High, Medium, Low). Strategies: Accept & Exploit, Accept & Co leverage, Accept & Transfer, Accept & Hold, Drop."
    $ws.Range("A2").Font.Italic = $true
    $ws.Range("A2").Font.Size = 9
    $ws.Range("A2").Font.Color = 0x555555

    $oppHeaders = @("Opportunity ID", "Title & Brief Description", "Source", "Category", "Cost of Expected Benefits ($)", "Cost of Implementation ($)", "Opportunity Value ($)", "Priority", "Response Strategy", "Action Plan & Ownership", "Status")
    for ($c = 0; $c -lt $oppHeaders.Count; $c++) {
        $colLetter = [char](65 + $c)
        Format-Header $ws.Range("${colLetter}3") $oppHeaders[$c] 0xF57F17
    }

    $opportunities = @(
        @("OPP-01", "AI Gear Recommendation & Size Predictor", "Technology", "Customer Experience", 55000, 14000, "Hot Pursuit", "Accept & Exploit", "Build in-house machine learning fit model; Sneha & Vikram", "Active"),
        @("OPP-02", "School & Youth Sports League Bulk Partnership Portal", "Business Development", "Revenue Expansion", 65000, 16000, "Hot Pursuit", "Accept & Co leverage", "Partner with National Youth Sports Alliance for joint co-branding; David Miller", "Active"),
        @("OPP-03", "24/7 Multilingual Live Customer Support Outsourcing", "Operations", "Cost Optimization", 22000, 8000, "Medium", "Accept & Transfer", "Transfer level-1 support to specialized Zendesk partner agency; Rajesh Sharma", "Under Review"),
        @("OPP-04", "Cryptocurrency & Web3 Wallet Payment Acceptance", "Market Trend", "Payment Channel", 6000, 9000, "Low", "Drop", "Drop opportunity due to negative net value (-$3,000) and regulatory volatility", "Dropped"),
        @("OPP-05", "Automated Cross-Border International Shipping Engine", "Expansion", "Global Logistics", 42000, 18000, "High", "Accept & Hold", "Hold until Q2 due to international tax and customs compliance legal clearance", "On Hold")
    )

    for ($i = 0; $i -lt $opportunities.Count; $i++) {
        $row = 4 + $i
        $ws.Range("A$row").Value2 = [string]$opportunities[$i][0]
        $ws.Range("B$row").Value2 = [string]$opportunities[$i][1]
        $ws.Range("C$row").Value2 = [string]$opportunities[$i][2]
        $ws.Range("D$row").Value2 = [string]$opportunities[$i][3]
        $ws.Range("E$row").Value2 = [double]$opportunities[$i][4] # Benefit
        $ws.Range("F$row").Value2 = [double]$opportunities[$i][5] # Cost
        $ws.Range("G$row").Formula = "=E$row - F$row"            # Value
        $ws.Range("H$row").Value2 = [string]$opportunities[$i][6] # Priority
        $ws.Range("I$row").Value2 = [string]$opportunities[$i][7] # Strategy
        $ws.Range("J$row").Value2 = [string]$opportunities[$i][8] # Action Plan
        $ws.Range("K$row").Value2 = [string]$opportunities[$i][9] # Status

        $ws.Range("E$row:G$row").NumberFormat = "$#,##0"
        $ws.Range("G$row").Font.Bold = $true
        $ws.Range("G$row").Interior.Color = 0xFFF8E1

        $stratCell = $ws.Range("I$row")
        $stratCell.Font.Bold = $true
        switch -wildcard ($opportunities[$i][7]) {
            "*Exploit*"     { $stratCell.Interior.Color = 0xC8E6C9; $stratCell.Font.Color = 0x1B5E20 }
            "*Co leverage*" { $stratCell.Interior.Color = 0xBBDEFB; $stratCell.Font.Color = 0x0D47A1 }
            "*Transfer*"    { $stratCell.Interior.Color = 0xFFE0B2; $stratCell.Font.Color = 0xE65100 }
            "*Hold*"        { $stratCell.Interior.Color = 0xE1BEE7; $stratCell.Font.Color = 0x4A148C }
            "*Drop*"        { $stratCell.Interior.Color = 0xFFCDD2; $stratCell.Font.Color = 0xB71C1C }
        }
    }
    Apply-TableBorders $ws.Range("A3:K8")

    $ws.Columns.Item(1).ColumnWidth = 14
    $ws.Columns.Item(2).ColumnWidth = 36
    $ws.Columns.Item(3).ColumnWidth = 20
    $ws.Columns.Item(4).ColumnWidth = 20
    $ws.Columns.Item(5).ColumnWidth = 20
    $ws.Columns.Item(6).ColumnWidth = 20
    $ws.Columns.Item(7).ColumnWidth = 20
    $ws.Columns.Item(8).ColumnWidth = 16
    $ws.Columns.Item(9).ColumnWidth = 22
    $ws.Columns.Item(10).ColumnWidth = 42
    $ws.Columns.Item(11).ColumnWidth = 16


    # ==========================================
    # 10. SHEET: Defects-Comments Data
    # ==========================================
    $ws = $wb.Worksheets.Item("Defects-Comments Data")
    $ws.Tab.Color = 0x4E342E # Brown

    $ws.Range("A1:I1").Merge()
    $ws.Range("A1").Value2 = "VERIFICATION DATA - DEFECTS & REVIEW COMMENTS LOG"
    $ws.Range("A1").Font.Bold = $true
    $ws.Range("A1").Font.Size = 14
    $ws.Range("A1").Font.Color = 0xFFFFFF
    $ws.Range("A1").Interior.Color = 0x4E342E
    $ws.Range("A1").HorizontalAlignment = -4108
    $ws.Range("A1").RowHeight = 30

    $ws.Range("A2:I2").Merge()
    $ws.Range("A2").Value2 = "Guidelines: 'Type' field indicates Review or Testing. 'Work Product' tracks the document/code verified. Date format: dd-MMM-yy."
    $ws.Range("A2").Font.Italic = $true
    $ws.Range("A2").Font.Size = 9
    $ws.Range("A2").Font.Color = 0x555555

    $defHeaders = @("Defect / Comment ID", "Type", "Work Product", "Description / Observation", "Severity", "Logged By", "Date Logged", "Assigned Owner", "Status")
    for ($c = 0; $c -lt $defHeaders.Count; $c++) {
        $colLetter = [char](65 + $c)
        Format-Header $ws.Range("${colLetter}3") $defHeaders[$c] 0x4E342E
    }

    $defects = @(
        @("DEF-001", "Review", "US-001 Auth Controller Code", "JWT refresh token expiration set to 30 days without revocation check", "Major", "Vikram Prajapati", "03-Nov-26", "Amit Verma", "Verified & Closed"),
        @("DEF-002", "Testing", "US-002 Catalog Filter Component", "Selecting soccer boots with size 11 threw null pointer in price formatter", "Minor", "Priya Nair", "04-Nov-26", "Sneha Kulkarni", "Verified & Closed"),
        @("DEF-003", "Testing", "US-005 Mini-Cart Component", "Subtotal calculation fails to apply regional sales tax until refresh", "Major", "Priya Nair", "08-Nov-26", "Sneha Kulkarni", "Verified & Closed"),
        @("DEF-004", "Review", "Checkout Flow UX Wireframes", "Missing guest checkout path; mandatory login required which increases friction", "Major", "David Miller", "10-Nov-26", "Sneha Kulkarni", "Verified & Closed"),
        @("DEF-005", "Testing", "US-006 Address Auto-complete", "ZIP code 5-digit regex rejected 9-digit ZIP+4 formatted addresses", "Minor", "Priya Nair", "13-Nov-26", "Amit Verma", "In Progress"),
        @("DEF-006", "Review", "Payment Webhook Handler", "Webhook retry handler lacks idempotency key check; risk of double charging", "Critical", "Vikram Prajapati", "14-Nov-26", "Amit Verma", "In Progress"),
        @("DEF-007", "Testing", "US-010 Jersey Customizer Canvas", "Special characters in player names rendered outside canvas boundary", "Minor", "Priya Nair", "15-Nov-26", "Sneha Kulkarni", "Open")
    )

    for ($i = 0; $i -lt $defects.Count; $i++) {
        $row = 4 + $i
        for ($c = 0; $c -lt $defects[$i].Count; $c++) {
            $colLetter = [char](65 + $c)
            $ws.Range("${colLetter}$row").Value2 = [string]$defects[$i][$c]
            $ws.Range("${colLetter}$row").VerticalAlignment = -4108
        }
        $ws.Range("G$row").NumberFormat = "dd-mmm-yy"
        $statusCell = $ws.Range("I$row")
        switch ($defects[$i][8]) {
            "Verified & Closed" { $statusCell.Interior.Color = 0xC8E6C9; $statusCell.Font.Color = 0x1B5E20; $statusCell.Font.Bold = $true }
            "In Progress"       { $statusCell.Interior.Color = 0xFFECB3; $statusCell.Font.Color = 0xE65100; $statusCell.Font.Bold = $true }
            "Open"              { $statusCell.Interior.Color = 0xFFCDD2; $statusCell.Font.Color = 0xB71C1C; $statusCell.Font.Bold = $true }
        }
    }
    Apply-TableBorders $ws.Range("A3:I10")

    $ws.Columns.Item(1).ColumnWidth = 18
    $ws.Columns.Item(2).ColumnWidth = 14
    $ws.Columns.Item(3).ColumnWidth = 28
    $ws.Columns.Item(4).ColumnWidth = 45
    $ws.Columns.Item(5).ColumnWidth = 14
    $ws.Columns.Item(6).ColumnWidth = 18
    $ws.Columns.Item(7).ColumnWidth = 14
    $ws.Columns.Item(8).ColumnWidth = 18
    $ws.Columns.Item(9).ColumnWidth = 18


    # ==========================================
    # 11. SHEET: Impediments Log
    # ==========================================
    $ws = $wb.Worksheets.Item("Impediments Log")
    $ws.Tab.Color = 0xD81B60 # Pink

    $ws.Range("A1:H1").Merge()
    $ws.Range("A1").Value2 = "IMPEDIMENTS LOG - EPIC SPORTS"
    $ws.Range("A1").Font.Bold = $true
    $ws.Range("A1").Font.Size = 14
    $ws.Range("A1").Font.Color = 0xFFFFFF
    $ws.Range("A1").Interior.Color = 0xD81B60
    $ws.Range("A1").HorizontalAlignment = -4108
    $ws.Range("A1").RowHeight = 30

    $impHeaders = @("Impediment ID", "Description of Impediment", "Raised By", "Date Raised", "Impact on Sprint", "Assigned Owner", "Resolution Action Plan", "Status")
    for ($c = 0; $c -lt $impHeaders.Count; $c++) {
        $colLetter = [char](65 + $c)
        Format-Header $ws.Range("${colLetter}3") $impHeaders[$c] 0xD81B60
    }

    $impediments = @(
        @("IMP-01", "Delays in receiving production-like sports catalog product photos and specs", "Sneha Kulkarni", "02-Nov-26", "High - delayed catalog cards", "David Miller (PO)", "PO provided cloud asset bucket with 500 validated product SKUs", "Resolved"),
        @("IMP-02", "Developer laptop firewall blocking Docker container local mesh networking", "Amit Verma", "04-Nov-26", "Medium - dev environment setup", "Rohan Mehta", "Created IT ticket; pushed updated corporate security group policy", "Resolved"),
        @("IMP-03", "Stripe sandbox developer account approval pending corporate tax ID verification", "Vikram Prajapati", "12-Nov-26", "High - blocking US-007 tests", "Ananya Roy (SM)", "Followed up with corporate finance; temporary testing key provided", "In Progress"),
        @("IMP-04", "Warehouse staging VPN gateway intermittent connection timeout", "Amit Verma", "14-Nov-26", "Medium - slows ERP sync tests", "Rohan Mehta", "Contacted warehouse network admin to increase keep-alive threshold", "Open")
    )

    for ($i = 0; $i -lt $impediments.Count; $i++) {
        $row = 4 + $i
        for ($c = 0; $c -lt $impediments[$i].Count; $c++) {
            $colLetter = [char](65 + $c)
            $ws.Range("${colLetter}$row").Value2 = [string]$impediments[$i][$c]
            $ws.Range("${colLetter}$row").VerticalAlignment = -4108
        }
        $ws.Range("D$row").NumberFormat = "dd-mmm-yy"
        $statusCell = $ws.Range("H$row")
        switch ($impediments[$i][7]) {
            "Resolved"    { $statusCell.Interior.Color = 0xC8E6C9; $statusCell.Font.Color = 0x1B5E20; $statusCell.Font.Bold = $true }
            "In Progress" { $statusCell.Interior.Color = 0xFFECB3; $statusCell.Font.Color = 0xE65100; $statusCell.Font.Bold = $true }
            "Open"        { $statusCell.Interior.Color = 0xFFCDD2; $statusCell.Font.Color = 0xB71C1C; $statusCell.Font.Bold = $true }
        }
    }
    Apply-TableBorders $ws.Range("A3:H7")

    $ws.Columns.Item(1).ColumnWidth = 16
    $ws.Columns.Item(2).ColumnWidth = 45
    $ws.Columns.Item(3).ColumnWidth = 18
    $ws.Columns.Item(4).ColumnWidth = 14
    $ws.Columns.Item(5).ColumnWidth = 24
    $ws.Columns.Item(6).ColumnWidth = 20
    $ws.Columns.Item(7).ColumnWidth = 45
    $ws.Columns.Item(8).ColumnWidth = 16


    # ==========================================
    # 12. SHEET: Action Items
    # ==========================================
    $ws = $wb.Worksheets.Item("Action Items")
    $ws.Tab.Color = 0x00695C # Teal

    $ws.Range("A1:G1").Merge()
    $ws.Range("A1").Value2 = "ACTION ITEMS REGISTER - EPIC SPORTS"
    $ws.Range("A1").Font.Bold = $true
    $ws.Range("A1").Font.Size = 14
    $ws.Range("A1").Font.Color = 0xFFFFFF
    $ws.Range("A1").Interior.Color = 0x00695C
    $ws.Range("A1").HorizontalAlignment = -4108
    $ws.Range("A1").RowHeight = 30

    $actHeaders = @("Action ID", "Action Item Description", "Source / Meeting Origin", "Assigned Owner", "Target Date", "Status", "Outcome / Notes")
    for ($c = 0; $c -lt $actHeaders.Count; $c++) {
        $colLetter = [char](65 + $c)
        Format-Header $ws.Range("${colLetter}3") $actHeaders[$c] 0x00695C
    }

    $actions = @(
        @("ACT-01", "Configure automated nightly regression tests on staging environment", "Sprint 1 Retrospective", "Priya Nair", "08-Nov-26", "Completed", "GitHub Actions cron configured; results piped to Slack #qa-reports"),
        @("ACT-02", "Refine user stories for custom team uniform configurator (US-010)", "Backlog Refinement", "David Miller & Vikram", "10-Nov-26", "Completed", "Added 5 concrete acceptance criteria and Canvas specs"),
        @("ACT-03", "Obtain client security sign-off for PCI-DSS tokenized checkout", "Daily Scrum", "Ananya Roy", "16-Nov-26", "In Progress", "Security team audit scheduled for Nov 16 at 2 PM EST"),
        @("ACT-04", "Benchmark Redis cart caching performance with 5,000 simulated users", "Architecture Review", "Amit Verma & Rohan", "19-Nov-26", "In Progress", "K6 load testing script written; execution planned"),
        @("ACT-05", "Set up live courier shipment tracking webhooks with FedEx sandbox", "Sprint 2 Planning", "Amit Verma", "22-Nov-26", "Open", "Awaiting FedEx developer sandbox API key")
    )

    for ($i = 0; $i -lt $actions.Count; $i++) {
        $row = 4 + $i
        for ($c = 0; $c -lt $actions[$i].Count; $c++) {
            $colLetter = [char](65 + $c)
            $ws.Range("${colLetter}$row").Value2 = [string]$actions[$i][$c]
            $ws.Range("${colLetter}$row").VerticalAlignment = -4108
        }
        $ws.Range("E$row").NumberFormat = "dd-mmm-yy"
        $statusCell = $ws.Range("F$row")
        switch ($actions[$i][5]) {
            "Completed"   { $statusCell.Interior.Color = 0xC8E6C9; $statusCell.Font.Color = 0x1B5E20; $statusCell.Font.Bold = $true }
            "In Progress" { $statusCell.Interior.Color = 0xFFECB3; $statusCell.Font.Color = 0xE65100; $statusCell.Font.Bold = $true }
            "Open"        { $statusCell.Interior.Color = 0xFFCDD2; $statusCell.Font.Color = 0xB71C1C; $statusCell.Font.Bold = $true }
        }
    }
    Apply-TableBorders $ws.Range("A3:G8")

    $ws.Columns.Item(1).ColumnWidth = 14
    $ws.Columns.Item(2).ColumnWidth = 45
    $ws.Columns.Item(3).ColumnWidth = 24
    $ws.Columns.Item(4).ColumnWidth = 22
    $ws.Columns.Item(5).ColumnWidth = 16
    $ws.Columns.Item(6).ColumnWidth = 16
    $ws.Columns.Item(7).ColumnWidth = 40


    # ==========================================
    # 13. SHEET: Story Clarity Index (SCI)
    # ==========================================
    $ws = $wb.Worksheets.Item("Story Clarity Index")
    $ws.Tab.Color = 0x2E7D32 # Green

    $ws.Range("A1:K1").Merge()
    $ws.Range("A1").Value2 = "STORY CLARITY INDEX (SCI) CALCULATOR - EPIC SPORTS"
    $ws.Range("A1").Font.Bold = $true
    $ws.Range("A1").Font.Size = 14
    $ws.Range("A1").Font.Color = 0xFFFFFF
    $ws.Range("A1").Interior.Color = 0x2E7D32
    $ws.Range("A1").HorizontalAlignment = -4108
    $ws.Range("A1").RowHeight = 30

    $ws.Range("A2:K2").Merge()
    $ws.Range("A2").Value2 = "Guidelines: Evaluates story clarity against 6 weighted criteria (Total Score out of 100). SCI >= 85: High Clarity (Ready); 70-84: Medium; <70: Low (Needs Refinement)."
    $ws.Range("A2").Font.Italic = $true
    $ws.Range("A2").Font.Size = 9
    $ws.Range("A2").Font.Color = 0x555555

    $sciHeaders = @("Story #", "User Story Title", "Persona Defined (15)", "Clear Business Value (20)", "Given-When-Then AC (25)", "Tech Dependencies (15)", "Sizing Feasibility (15)", "NFR Defined (10)", "SCI Score (%)", "Clarity Level", "Sprint Readiness")
    for ($c = 0; $c -lt $sciHeaders.Count; $c++) {
        $colLetter = [char](65 + $c)
        Format-Header $ws.Range("${colLetter}3") $sciHeaders[$c] 0x2E7D32
    }

    $sciScores = @(
        @(15, 20, 25, 15, 15, 10), # US-001 (100%)
        @(15, 20, 25, 15, 15, 8),  # US-002 (98%)
        @(15, 20, 25, 14, 15, 9),  # US-003 (98%)
        @(15, 20, 23, 14, 15, 8),  # US-004 (95%)
        @(15, 18, 24, 15, 14, 9),  # US-005 (95%)
        @(15, 20, 25, 15, 14, 8),  # US-006 (97%)
        @(15, 20, 25, 15, 13, 9),  # US-007 (97%)
        @(14, 18, 22, 14, 15, 7),  # US-008 (90%)
        @(14, 18, 23, 13, 14, 8),  # US-009 (90%)
        @(15, 19, 24, 12, 12, 6),  # US-010 (88%)
        @(13, 17, 21, 12, 13, 7),  # US-011 (83%)
        @(14, 18, 22, 14, 14, 8),  # US-012 (90%)
        @(12, 15, 18, 11, 14, 6),  # US-013 (76%)
        @(14, 17, 22, 12, 13, 7),  # US-014 (85%)
        @(15, 19, 23, 13, 14, 8)   # US-015 (92%)
    )

    for ($i = 0; $i -lt $sciScores.Count; $i++) {
        $row = 4 + $i
        $backlogRow = 4 + $i
        $ws.Range("A$row").Formula = "='Product Backlog'!A$backlogRow"
        $ws.Range("B$row").Formula = "='Product Backlog'!C$backlogRow"
        $ws.Range("A$row:B$row").Interior.Color = 0xE8F5E9

        $ws.Range("C$row").Value2 = [double]$sciScores[$i][0]
        $ws.Range("D$row").Value2 = [double]$sciScores[$i][1]
        $ws.Range("E$row").Value2 = [double]$sciScores[$i][2]
        $ws.Range("F$row").Value2 = [double]$sciScores[$i][3]
        $ws.Range("G$row").Value2 = [double]$sciScores[$i][4]
        $ws.Range("H$row").Value2 = [double]$sciScores[$i][5]

        # Total SCI Score formula
        $ws.Range("I$row").Formula = "=SUM(C$row:H$row)"
        $ws.Range("I$row").Font.Bold = $true
        $ws.Range("I$row").Interior.Color = 0xC8E6C9
        $ws.Range("I$row").HorizontalAlignment = -4108

        # Clarity level formula
        $ws.Range("J$row").Formula = "=IF(I$row>=85, ""High Clarity"", IF(I$row>=70, ""Medium Clarity"", ""Low Clarity""))"
        $ws.Range("J$row").Font.Bold = $true
        $ws.Range("J$row").HorizontalAlignment = -4108

        # Readiness formula
        $ws.Range("K$row").Formula = "=IF(I$row>=85, ""Ready for Sprint"", IF(I$row>=70, ""Needs Minor Grooming"", ""Not Ready""))"
        $ws.Range("K$row").Font.Bold = $true
        $ws.Range("K$row").HorizontalAlignment = -4108

        $ws.Range("C$row:H$row").HorizontalAlignment = -4108
    }

    # Average SCI Summary
    $avgRow = 4 + $sciScores.Count
    $ws.Range("A$avgRow:H$avgRow").Merge()
    $ws.Range("A$avgRow").Value2 = "AVERAGE BACKLOG STORY CLARITY INDEX (SCI)"
    $ws.Range("A$avgRow").Font.Bold = $true
    $ws.Range("A$avgRow").HorizontalAlignment = -4108
    $ws.Range("A$avgRow:K$avgRow").Interior.Color = 0xA5D6A7
    $ws.Range("I$avgRow").Formula = "=AVERAGE(I4:I$($avgRow-1))"
    $ws.Range("I$avgRow").Font.Bold = $true
    $ws.Range("I$avgRow").NumberFormat = "0.0"
    $ws.Range("I$avgRow").HorizontalAlignment = -4108
    $ws.Range("J$avgRow:K$avgRow").Merge()
    $ws.Range("J$avgRow").Value2 = "Overall Backlog Readiness: High (>= 90%)"
    $ws.Range("J$avgRow").Font.Bold = $true
    $ws.Range("J$avgRow").HorizontalAlignment = -4108
    Apply-TableBorders $ws.Range("A3:K19")

    $ws.Columns.Item(1).ColumnWidth = 12
    $ws.Columns.Item(2).ColumnWidth = 35
    $ws.Columns.Item(3).ColumnWidth = 20
    $ws.Columns.Item(4).ColumnWidth = 22
    $ws.Columns.Item(5).ColumnWidth = 22
    $ws.Columns.Item(6).ColumnWidth = 20
    $ws.Columns.Item(7).ColumnWidth = 20
    $ws.Columns.Item(8).ColumnWidth = 18
    $ws.Columns.Item(9).ColumnWidth = 16
    $ws.Columns.Item(10).ColumnWidth = 18
    $ws.Columns.Item(11).ColumnWidth = 22

    # Enable gridlines and clean print setup across all sheets
    for ($s = 1; $s -le $wb.Worksheets.Count; $s++) {
        $sheet = $wb.Worksheets.Item($s)
        try {
            $sheet.PageSetup.Orientation = 2 # xlLandscape
            $sheet.PageSetup.FitToPagesWide = 1
            $sheet.PageSetup.FitToPagesTall = $false
            $sheet.PageSetup.PrintGridlines = $true
        } catch { }
    }

    # Save and Close
    $wb.SaveAs($outputPath)
    $wb.Close($true)
    Write-Output "Production-Ready Workbook successfully generated at: $outputPath"
}
finally {
    $excel.Quit()
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel) | Out-Null
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
}
