require "ecr/macros"

module Crystal::Doc
  record TypeTemplate, type do
    ecr_file [__DIR__, "html", "type.html"].join(File::SEPARATOR_STRING)
  end

  record ListTemplate, types do
    ecr_file [__DIR__, "html", "list.html"].join(File::SEPARATOR_STRING)
  end

  record ListItemsTemplate, types do
    ecr_file [__DIR__, "html", "list_items.html"].join(File::SEPARATOR_STRING)
  end

  record MethodSummaryTemplate, title, methods do
    ecr_file [__DIR__, "html", "method_summary.html"].join(File::SEPARATOR_STRING)
  end

  record MethodDetailTemplate, title, methods do
    ecr_file [__DIR__, "html", "method_detail.html"].join(File::SEPARATOR_STRING)
  end

  record OtherTypesTemplate, title, type, other_types do
    ecr_file [__DIR__, "html", "other_types.html"].join(File::SEPARATOR_STRING)
  end

  record MainTemplate, body do
    ecr_file [__DIR__, "html", "main.html"].join(File::SEPARATOR_STRING)
  end

  struct IndexTemplate
    ecr_file [__DIR__, "html", "index.html"].join(File::SEPARATOR_STRING)
  end

  struct JsTypeTemplate
    ecr_file "#{__DIR__}/html/js/type.js"
  end

  struct StyleTemplate
    ecr_file [__DIR__, "html", "css", "style.css"].join(File::SEPARATOR_STRING)
  end
end
