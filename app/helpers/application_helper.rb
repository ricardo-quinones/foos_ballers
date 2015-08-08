module ApplicationHelper
  def panel_attrs(panel, ng_controller)
    attrs = { "ng-class"=>"{'open-panel': openPanel.#{panel}}" }
    attrs.merge!("ng-controller" => ng_controller) if ng_controller
    attrs
  end
end
