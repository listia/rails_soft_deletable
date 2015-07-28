require "rails_helper"

describe RailsSoftDeletable do
  let (:model) { IntegerModel.create! }
  let (:decimal_model) { DecimalModel.create!(integer_model_id: model.id) }
  let (:integer_model) { IntegerModel.create! }
  let (:forest) { Forest.create! }
  let (:park) { Park.create! }

  context ".with_deleted" do
    it "returns both non deleted and soft deleted object" do
      model.destroy

      expect(IntegerModel.with_deleted).to include(model, integer_model)
    end

    context "when using with_deleted with associations" do
      let! (:decimal_model2) { DecimalModel.create!(integer_model_id: integer_model.id) }

      it "returns both non deleted and soft deleted object that realated to association" do
        decimal_model.destroy

        expect(model.decimal_models.with_deleted.to_a).to eq([decimal_model])
      end

      it "only affects the associations or model it touch" do
        decimal_model.destroy

        expect(IntegerModel.with_deleted.joins(:decimal_models).pluck(:id)).to eq([integer_model.id])
      end

      context "when access with_deleted associations with joins" do
        it "returns both non deleted and soft deleted object that realated to association" do
          # `unscoped` not being respected for Rails >= 4.0 when joining table, this issue remains unsolved.
          # For example:
          #   In IntegerModel:
          #     has_many :decimal_models_with_deleted, -> { unscope where: :deleted_at }, class_name: "DecimalModel"
          #
          #   IntegerModel.with_deleted.joins(:decimal_models_with_deleted).to_sql
          #   => "SELECT \"integer_models\".* FROM \"integer_models\" INNER JOIN \"decimal_models\" ON \"decimal_models\".\"integer_model_id\" = \"integer_models\".\"id\" AND \"decimal_models\".\"deleted_at\" = 0"
          #
          # Related issue: https://github.com/rails/rails/issues/13775
          # Related PR: https://github.com/rails/rails/pull/18109
          #
          # The only solution is to using raw sql join to remove the default scope
          expect(IntegerModel.with_deleted.
                 joins("join decimal_models on decimal_models.integer_model_id = integer_models.id").pluck(:id)).
                 to eq([integer_model.id])
        end
      end
    end
  end

  context ".only_deleted" do
    it "returns only deleted object" do
      model.destroy

      expect(IntegerModel.only_deleted).to include(model)
      expect(IntegerModel.only_deleted).not_to include(integer_model)
    end
  end

  context "with associations" do
    context "model with soft_deletable" do
      context ".belongs_to" do
        context "with deleted option" do
          before do
            Tree.belongs_to(:forest, with_deleted: true)
            forest.destroy
            @tree = Tree.create!(forest_id: forest.id)
          end

          it "returns associated objects" do
            expect(@tree.forest).to eq(forest)
          end
        end

        context "without deleted option" do
          before do
            Tree.belongs_to(:forest)
            forest.destroy
            @tree = Tree.create!(forest_id: forest.id)
          end

          it "does not return deleted associated objects" do
            expect(@tree.forest).to be_nil
          end
        end
      end

      context ".has_many" do
        context "with deleted option" do
          before do
            Forest.has_many(:trees, with_deleted: true)
            @tree_destroyed = Tree.create!(forest_id: forest.id)
            @tree_destroyed.destroy
            @tree = Tree.create!(forest_id: forest.id)
          end

          it "returns all associated objects" do
            expect(forest.trees).to include(@tree_destroyed, @tree)
          end
        end

        context "without deleted option" do
          before do
            Forest.has_many(:trees)
            Tree.create!(forest_id: forest.id).destroy
          end

          it "returns empty" do
            expect(forest.trees).to be_empty
          end
        end
      end

      context ".has_one" do
        context "with deleted option" do
          before do
            Forest.has_one(:tree, -> { where(biggest: true) }, with_deleted: true)
            @tree = Tree.create!(forest_id: forest.id, biggest: true)
            @tree.destroy
          end

          it "returns deleted object" do
            expect(forest.tree).to eq(@tree)
          end
        end

        context "without deleted option" do
          before do
            Forest.has_one(:tree, -> { where(biggest: true) })
            Tree.create!(forest_id: forest.id, biggest: true).destroy
          end

          it "returns nil" do
            expect(forest.tree).to be_nil
          end
        end
      end
    end

    context "model without soft_deletable" do
      context ".belongs_to" do
        context "with deleted option" do
          before do
            Park.belongs_to(:forest, with_deleted: true)
            forest.destroy
            park.forest = forest
            park.save
          end

          it "returns associated objects" do
            expect(park.reload.forest).to eq(forest)
          end
        end

        context "without deleted option" do
          before do
            Park.belongs_to(:forest)
            forest.destroy
            park.forest = forest
            park.save
          end

          it "does not return deleted associated objects" do
            expect(park.reload.forest).to be_nil
          end
        end
      end

      context ".has_many" do
        context "with deleted option" do
          before do
            Park.has_many(:trees, with_deleted: true)
            @tree_destroyed = Tree.create!(park_id: park.id)
            @tree_destroyed.destroy
            @tree = Tree.create!(park_id: park.id)
          end

          it "returns all associated objects" do
            expect(park.trees).to include(@tree_destroyed, @tree)
          end
        end

        context "without deleted option" do
          before do
            Park.has_many(:trees)
            Tree.create!(park_id: park.id).destroy
          end

          it "returns empty" do
            expect(park.trees).to be_empty
          end
        end
      end

      context ".has_one" do
        context "with deleted option" do
          before do
            Park.has_one(:tree, -> { where(biggest: true) }, with_deleted: true)
            @tree = Tree.create!(park_id: park.id, biggest: true)
            @tree.destroy
          end

          it "returns deleted object" do
            expect(park.tree).to eq(@tree)
          end
        end

        context "without deleted option" do
          before do
            Park.has_one(:tree, -> { where(biggest: true) })
            Tree.create!(park_id: park.id, biggest: true).destroy
          end

          it "returns nil" do
            expect(park.tree).to be_nil
          end
        end
      end
    end
  end

  context "#destroy" do
    it "marks deleted_at column" do
      Timecop.freeze(Time.now) do
        decimal_model.destroy
        integer_model.destroy

        raw_decimal_deleted_at = DecimalModel.connection.select_value("SELECT deleted_at FROM #{DecimalModel.quoted_table_name} WHERE #{DecimalModel.primary_key} = #{decimal_model.id}")
        raw_integer_deleted_at = IntegerModel.connection.select_value("SELECT deleted_at FROM #{IntegerModel.quoted_table_name} WHERE #{IntegerModel.primary_key} = #{integer_model.id}")

        expect(raw_decimal_deleted_at).to eq(("%0.6f" % Time.now.to_f).to_f)
        expect(raw_integer_deleted_at.to_i).to eq(Time.now.to_i)
      end
    end

    it "soft deletes the record" do
      Timecop.freeze(Time.now.round) do
        decimal_model.destroy
        integer_model.destroy

        expect(decimal_model.deleted_at).to eq(("%0.6f" % Time.now.to_f).to_f)
        expect(integer_model.deleted_at).to eq(Time.now.to_i)

        expect(decimal_model.soft_delete_time).to eq(Time.now.in_time_zone)
        expect(integer_model.soft_delete_time.to_i).to eq(Time.now.to_i)
      end
    end

    it "does not mark the deleted_at attribute as changed" do
      model.destroy

      expect(model).to_not be_deleted_at_changed
    end

    it "marks the record as destroyed" do
      model.destroy

      expect(model).to be_destroyed
    end

    it "marks the record as not persisted" do
      model.destroy

      expect(model).to_not be_persisted
    end

    it "does not freeze the record" do
      model.destroy

      expect(decimal_model).to_not be_frozen
    end

    it "performs destroy callbacks" do
      model.destroy

      expect(model.before_destroy_called).to eq(1)
      expect(model.around_destroy_called).to eq(2)
      expect(model.after_destroy_called).to eq(3)
    end

    it "performs commit callbacks" do
      model.destroy

      expect(model.after_commit_called).to eq(4)
      expect(model.after_commit_called).to be > model.after_destroy_called
    end

    context "when record has already been soft deleted" do
      before do
        model.destroy
        model.reset_callback_flags!
      end

      it "continues to call destroy callbacks" do
        model.destroy

        expect(model.before_destroy_called).to eq(1)
        expect(model.around_destroy_called).to eq(2)
        expect(model.after_destroy_called).to eq(3)
      end
    end

    context "with hard destroy mode" do
      it "hard deletes the record from the database" do
        model.destroy(:hard)

        count = model.class.connection.select_value("SELECT COUNT(*) FROM #{model.class.quoted_table_name} WHERE #{model.class.primary_key} = #{model.id}")
        expect(count).to eq(0)
      end

      it "performs destroy callbacks" do
        model.destroy(:hard)

        expect(model.before_destroy_called).to eq(1)
        expect(model.around_destroy_called).to eq(2)
        expect(model.after_destroy_called).to eq(3)
      end
    end
  end

  context "#delete" do
    it "marks deleted_at column" do
      Timecop.freeze(Time.now) do
        decimal_model.delete
        integer_model.delete

        raw_decimal_deleted_at = DecimalModel.connection.select_value("SELECT deleted_at FROM #{DecimalModel.quoted_table_name} WHERE #{DecimalModel.primary_key} = #{decimal_model.id}")
        raw_integer_deleted_at = IntegerModel.connection.select_value("SELECT deleted_at FROM #{IntegerModel.quoted_table_name} WHERE #{IntegerModel.primary_key} = #{integer_model.id}")

        expect(raw_decimal_deleted_at).to eq(("%0.6f" % Time.now.to_f).to_f)
        expect(raw_integer_deleted_at.to_i).to eq(Time.now.to_i)
      end
    end

    it "soft deletes the record" do
      Timecop.freeze(Time.now.round) do
        decimal_model.delete
        integer_model.delete

        expect(decimal_model.deleted_at).to eq(("%0.6f" % Time.now.to_f).to_f)
        expect(integer_model.deleted_at.to_i).to eq(Time.now.to_i)

        expect(decimal_model.soft_delete_time).to eq(Time.now.in_time_zone)
        expect(integer_model.soft_delete_time.to_i).to eq(Time.now.to_i)
      end
    end

    it "does not mark the deleted_at attribute as changed" do
      model.delete

      expect(model).to_not be_deleted_at_changed
    end

    it "marks the record as destroyed" do
      model.delete

      expect(model).to be_destroyed
    end

    it "marks the record as not persisted" do
      model.delete

      expect(model).to_not be_persisted
    end

    it "does not freeze the record" do
      model.delete

      expect(decimal_model).to_not be_frozen
    end

    it "does not perform destroy callbacks" do
      model.delete

      expect(model.before_destroy_called).to be_nil
      expect(model.around_destroy_called).to be_nil
      expect(model.after_destroy_called).to be_nil
    end

    context "when record has already been soft deleted" do
      before do
        model.delete
      end

      it "does not perform destroy callbacks" do
        model.delete

        expect(model.before_destroy_called).to be_nil
        expect(model.around_destroy_called).to be_nil
        expect(model.after_destroy_called).to be_nil
      end
    end

    context "with hard delete mode" do
      it "hard deletes the record from the database" do
        model.delete(:hard)

        count = model.class.connection.select_value("SELECT COUNT(*) FROM #{model.class.quoted_table_name} WHERE #{model.class.primary_key} = #{model.id}")
        expect(count).to eq(0)
      end

      it "performs destroy callbacks" do
        model.delete(:hard)

        expect(model.before_destroy_called).to be_nil
        expect(model.around_destroy_called).to be_nil
        expect(model.after_destroy_called).to be_nil
      end
    end
  end

  context "#restore!" do
    before do
      model.destroy
      model.reset_callback_flags!
    end

    it "restores the record" do
      model.restore!

      expect(model).to be_persisted
      expect(model.soft_delete_time).to be_nil
      expect(model).to_not be_deleted_at_changed
      expect(model).to_not be_destroyed
      expect(model).to_not be_new_record
      expect(model).to_not be_frozen
    end

    it "resets deleted_at in the database" do
      model.restore!

      model_deleted_at = model.class.connection.select_value("SELECT deleted_at FROM #{model.class.quoted_table_name} WHERE #{model.class.primary_key} = #{model.id}")
      expect(model_deleted_at).to eq(0)
    end

    it "performs restore callbacks" do
      model.restore!

      expect(model.before_restore_called).to eq(1)
      expect(model.around_restore_called).to eq(2)
      expect(model.after_restore_called).to eq(3)
    end

    it "returns true" do
      expect(model.restore!).to eq(true)
    end
  end

  context "#soft_delete_time" do
    context "when record has not been soft deleted" do
      it "returns nil" do
        expect(model.soft_delete_time).to be_nil
      end
    end

    context "when record has been soft deleted" do
      before do
        model.destroy
      end

      it "returns a Time object" do
        expect(model.soft_delete_time).to be_kind_of(Time)
      end
    end
  end
end
